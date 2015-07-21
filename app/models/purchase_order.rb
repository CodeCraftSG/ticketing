class PurchaseOrder < ActiveRecord::Base
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
        name: order.ticket_type.name,
        description: order.ticket_type.description,
        quantity: order.quantity,
        amount: order.total_amount_cents
      }
    else
      {
        name: 'Event Tickets',
        description: orders.map{|o| "#{o.ticket_type.name}(#{o.quantity})" }.join(', '),
        quantity: 1,
        amount: total_amount_cents
      }
    end
  end

  def purchase(token)
    details = EXPRESS_GATEWAY.details_for(token)

    update(
      express_payer_id: details.payer_id,
      express_token: token
    )

    response = EXPRESS_GATEWAY.purchase(total_amount_cents, express_purchase_options)
    if response.success?
      update(status: 'success', purchased_at: Time.now)
    else
      Rails.logger.error "Exception: Payment Unsuccessful for #{payment_token} - #{response.message}"
      raise StandardError, response.message
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
      currency: CURRENCY
    }
  end
end
