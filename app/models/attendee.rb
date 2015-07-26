class Attendee < ActiveRecord::Base
  has_paper_trail

  validates_presence_of [:first_name, :last_name, :email, :size]
  validates_email_format_of :email

  has_many :tickets
end
