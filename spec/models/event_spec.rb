require 'rails_helper'

RSpec.describe Event, type: :model do
  describe 'associations' do
    it { should have_many(:ticket_types).dependent(:destroy) }
    it { should have_many(:orders).through(:ticket_types) }
    it { should have_many(:tickets).through(:orders) }
    it { should have_many(:attendees).through(:tickets) }
    it { should have_many(:purchase_orders).dependent(:destroy) }
  end
end
