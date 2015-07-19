class PurchaseOrder < ActiveRecord::Base
  has_many :orders
  has_many :tickets, through: :orders
  has_many :attendees, through: :tickets

  def total_amount
    calculate_amount if total_amount_cents.nil?
    (total_amount_cents.to_f / 100).round(2)
  end

  def calculate_amount
    self.total_amount_cents = orders.inject(0){|sum, order| sum + order.total_amount_cents}

    self
  end
end
