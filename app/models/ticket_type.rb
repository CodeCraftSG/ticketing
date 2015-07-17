class TicketType < ActiveRecord::Base
  belongs_to :event
  has_many :orders
  has_many :tickets, through: :orders
  has_many :attendees, through: :tickets
end
