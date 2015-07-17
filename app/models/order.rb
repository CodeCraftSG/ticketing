class Order < ActiveRecord::Base
  belongs_to :ticket_type
  has_many :tickets
  has_many :attendees, through: :tickets
end
