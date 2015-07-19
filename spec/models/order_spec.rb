require 'rails_helper'

RSpec.describe Order, type: :model do
  describe '#total_amount' do
    it 'returns total_amount_cents in 2 decimal currency value' do
      order = Order.new(total_amount_cents: 19999)

      expect(order.total_amount).to eq 199.99
    end
  end

  describe '#calculate_amount' do
    it 'returns total_amount_cents in 2 decimal currency value' do
      ticket_type = TicketType.new(price: 200.50)
      order = Order.new(quantity: 2, ticket_type: ticket_type)

      order.calculate_amount
      expect(order.total_amount_cents).to eq 40100
    end
  end
end
