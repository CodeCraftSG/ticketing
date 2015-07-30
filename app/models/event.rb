class Event < ActiveRecord::Base
  has_paper_trail

  has_many :ticket_types, dependent: :destroy
  has_many :orders, through: :ticket_types
  has_many :tickets, through: :orders
  has_many :attendees, through: :tickets
  has_many :purchase_orders, dependent: :destroy
end
