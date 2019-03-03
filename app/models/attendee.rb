class Attendee < ActiveRecord::Base
  has_paper_trail

  before_create :auto_public_id

  validates_presence_of [:first_name, :last_name, :email]
  validates_email_format_of :email

  has_many :tickets

  def auto_public_id
    self.public_id = SecureRandom.uuid
  end
end
