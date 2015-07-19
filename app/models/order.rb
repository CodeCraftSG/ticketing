class Order < ActiveRecord::Base
  belongs_to :ticket_type
  has_many :tickets
  has_many :attendees, through: :tickets

  def total_amount
    (total_amount_cents.to_f / 100).round(2)
  end
end
