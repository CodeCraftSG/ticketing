require 'rails_helper'

RSpec.describe Order, type: :model do
  describe '#total_amount' do
    it 'returns total_amount_cents in 2 decimal currency value' do
      order = Order.new(total_amount_cents: 19999)

      expect(order.total_amount).to eq 199.99
    end
  end
end
