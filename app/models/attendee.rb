class Attendee < ActiveRecord::Base
  has_paper_trail

  has_many :tickets
end
