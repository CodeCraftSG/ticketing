class TicketType < ActiveRecord::Base
  has_paper_trail

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
      coupon_code_ticket = active.with_code(code).first
      if coupon_code_ticket.present? && coupon_code_ticket.standalone?
        available = with_code(code)
      else
        available = available.
                      union(
                        self.active.with_code(code)
                      )
      end
    end

    available.order("sequence ASC")
  end

  def available?(date=DateTime.now)
    sale_starts_at <= date && sale_ends_at > date
  end

  def currency_symbol
    PurchaseOrder::VALID_CURRENCIES[currency_unit]
  end
end
