class PurchaseOrder < ActiveRecord::Base
  has_paper_trail

  belongs_to :event
  has_many :orders, dependent: :destroy
  has_many :tickets, through: :orders
  has_many :attendees, through: :tickets
  before_create :set_payment_token
  before_validation :calculate_amount

  accepts_nested_attributes_for :orders, allow_destroy: true

  validates_presence_of :payer_first_name, :payer_last_name, :payer_email, if: :needs_payment_info_early?
  validates_email_format_of :payer_email, if: :needs_payment_info_early?

  VALID_CURRENCIES = {'SGD' => '$','BTC' => '฿'}
  CURRENCY = 'SGD'

  enum status: {pending: 0, success: 1, cancelled: 2}

  def total_amount
    calculate_amount if total_amount_cents.nil?
    (total_amount_cents.to_f / 100).round(2)
  end

  def calculate_amount
    self.total_amount_cents = orders.inject(0){|sum, order| sum + order.calculate_amount.total_amount_cents}

    self
  end

  def name
    "#{event.name} - Event Tickets"
  end

  def description
    return '' if orders.empty? == 0
    if orders.count == 1
      order = orders.first
      "#{order.ticket_type.name} (#{order.quantity * order.ticket_type.entitlement} tickets)"
    else
      orders.map{|o| "#{o.ticket_type.name} (#{o.quantity * o.ticket_type.entitlement} tickets)" }.join(', ')
    end
  end

  def build_payment_params
    calculate_amount unless total_amount_cents

    {
      name: name,
      description: description,
      quantity: 1,
      amount: total_amount_cents
    }
  end

  def purchase(token)
    details = EXPRESS_GATEWAY.details_for(token)

    update(
      express_payer_id: details.payer_id,
      express_token: token,
      notes: "PayPal Express Payment: #{details.note}",
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
    payment_details = JSON.parse(raw_payment_details)

    if payment_details['TransactionId']
      payment_details['TransactionId']
    else
      payment_details['balance_transaction']
    end
  rescue
    nil
  end

  def auto_invoice_no
    "INV-%s-%08d" % [created_at.strftime('%Y%m%d'), id]
  end

  def currency_unit
    return orders.first.ticket_type.currency_unit if orders.present?

    CURRENCY
  end

  def currency_symbol
    VALID_CURRENCIES[currency_unit]
  end

  def transaction_details_hash
    return {} unless raw_payment_details.present?

    JSON.parse(raw_payment_details, symbolize_names: true) rescue {}
  end

  def needs_payment_info_early?
    return true if total_amount == 0.0
    return true if orders.size==1 && orders.first.ticket_type.currency_unit == 'BTC'

    false
  end

  def entitlements
    orders.reduce(0) do |sum, order|
      sum + (order.ticket_type.entitlement * order.quantity)
    end
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
      currency: currency_unit
    }
  end
end
