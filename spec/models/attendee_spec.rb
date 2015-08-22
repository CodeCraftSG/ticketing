require 'rails_helper'

RSpec.describe Attendee, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }
    it { should validate_presence_of(:email) }
    it { should validate_email_format_of(:email) }
    it { should validate_presence_of(:size) }
    it { should validate_presence_of(:cutting) }
  end

  describe 'associations' do
    it { should have_many(:tickets) }
  end
end
