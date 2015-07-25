class PurchaseOrder < ActiveRecord::Base
  has_paper_trail

  belongs_to :event
  has_many :orders
  has_many :tickets, through: :orders
  has_many :attendees, through: :tickets
  before_create :set_payment_token

  CURRENCY = 'SGD'

  enum status: {pending: 0, success: 1, cancelled: 2}

  def total_amount
    calculate_amount if total_amount_cents.nil?
    (total_amount_cents.to_f / 100).round(2)
  end

  def calculate_amount
    self.total_amount_cents = orders.inject(0){|sum, order| sum + order.total_amount_cents}

    self
  end

  def build_payment_params
    if orders.count == 1
      order = orders.first
      {
        name: "#{event.name} - Event Tickets",
        description: "#{order.ticket_type.name} (#{order.quantity} tickets)",
        quantity: order.quantity,
        amount: order.total_amount_cents
      }
    else
      {
        name: "#{event.name} - Event Tickets",
        description: orders.map{|o| "#{o.ticket_type.name} (#{o.quantity} tickets)" }.join(', '),
        quantity: 1,
        amount: total_amount_cents
      }
    end
  end

  def purchase(token)
    details = EXPRESS_GATEWAY.details_for(token)

    update(
      express_payer_id: details.payer_id,
      express_token: token,
      notes: details.note,
      payer_address: details.address.to_json,
      payer_email: details.email,
      payer_salutation: details.info['PayerName']['Salutation'],
      payer_first_name: details.info['PayerName']['FirstName'],
      payer_last_name: details.info['PayerName']['LastName'],
      payer_country: details.payer_country,
      raw_payment_details: details.details.to_json
    )

    response = EXPRESS_GATEWAY.purchase(total_amount_cents, express_purchase_options)
    if response.success?
      new_details = EXPRESS_GATEWAY.details_for(token)
      update(status: 'success', purchased_at: Time.now, invoice_no: auto_invoice_no, raw_payment_details: new_details.details.to_json)
      OrdersMailer.payment_successful(self).deliver_later
    else
      Rails.logger.error "Exception: Payment Unsuccessful for #{payment_token} - #{response.error_code} #{response.message} #{response.params}"
      raise StandardError, response.message unless response.params["error_codes"].include?('10415')
    end
  end

  def transaction_id
    JSON.parse(raw_payment_details)['TransactionId']
  end

  private

  def set_payment_token
    self.payment_token = SecureRandom.uuid
  end

  def express_purchase_options
    {
      ip: ip,
      token: express_token,
      payer_id: express_payer_id,
      currency: CURRENCY
    }
  end

  def auto_invoice_no
    "INV-%s-%08d" % [created_at.strftime('%Y%m%d'), id]
  end
end
