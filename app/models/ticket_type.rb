class TicketType < ActiveRecord::Base
  belongs_to :event
  has_many :orders
  has_many :tickets, through: :orders
  has_many :attendees, through: :tickets

  scope :active, -> { where(active: true) }
  scope :visible, -> { where(hidden: false) }
  scope :with_code, -> (code) { where(code: code) }
  scope :available_for_sale_at, -> (date) { where("sale_starts_at <= :ref_date AND sale_ends_at > :ref_date", {ref_date: date}) }

  def self.tickets_available(code: nil)
    available = active.visible

    if code
      available = available.
                    union(
                      self.active.with_code(code)
                    )
    end

    available.order("sequence ASC")
  end

  def available?(date=DateTime.now)
    sale_starts_at <= date && sale_ends_at > date
  end
end
