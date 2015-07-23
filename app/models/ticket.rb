class Ticket < ActiveRecord::Base
  has_paper_trail

  belongs_to :order
  belongs_to :attendee
end
