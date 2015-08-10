require 'rails_helper'

RSpec.describe Order, type: :model do
  describe 'validations' do
    it { should validate_numericality_of(:quantity).is_greater_than(0) }
  end

  describe 'associations' do
    it { should belong_to(:purchase_order) }
    it { should belong_to(:ticket_type) }
    it { should have_many(:tickets).dependent(:destroy) }
    it { should have_many(:attendees).through(:tickets).dependent(:destroy) }
  end

  describe '#total_amount' do
    it 'returns total_amount_cents in 2 decimal currency value' do
      order = FactoryGirl.build :order, total_amount_cents: 19999

      expect(order.total_amount).to eq 199.99
    end
  end

  describe '#calculate_amount' do
    it 'returns total_amount_cents in 2 decimal currency value' do
      ticket_type = FactoryGirl.build :ticket_type, price: 200.50
      order = FactoryGirl.build :order, quantity: 2, ticket_type: ticket_type

      order.calculate_amount
      expect(order.total_amount_cents).to eq 40100
    end
  end

  describe '#send_attendee_notifications' do
    xit 'calls OrderMailer' do
      order = FactoryGirl.build :order

    end
  end
end
