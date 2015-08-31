class Order < ActiveRecord::Base
  has_paper_trail

  validates_numericality_of :quantity, greater_than: 0

  belongs_to :purchase_order
  belongs_to :ticket_type
  has_many :tickets, dependent: :destroy
  has_many :attendees, through: :tickets, dependent: :destroy
  before_validation :calculate_amount

  def total_amount
    calculate_amount if total_amount_cents.nil? && quantity > 0
    (total_amount_cents.to_f / 100).round(2)
  end

  def calculate_amount
    self.total_amount_cents = quantity * ticket_type.price * 100 if ticket_type

    self
  end

  def ticket_entitlement
    return 0 unless ticket_type.present?
    ticket_type.entitlement * quantity
  end

  def send_attendee_notifications
    tickets.each do |ticket|
      OrdersMailer.attendee_notification(purchase_order, ticket).deliver_later
    end
  end
end
