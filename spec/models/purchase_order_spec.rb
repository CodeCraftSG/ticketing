require 'rails_helper'

RSpec.describe PurchaseOrder, type: :model do
  describe '#total_amount' do
    it 'returns total_amount_cents in 2 decimal currency value' do
      purchase_order = PurchaseOrder.new(total_amount_cents: 19999)

      expect(purchase_order.total_amount).to eq 199.99
    end
  end

  describe '#calculate_amount' do
    it 'returns total_amount_cents in 2 decimal currency value' do
      purchase_order = PurchaseOrder.new

      ticket_type = TicketType.new(price: 200.50)
      order1 = Order.new(quantity: 2, ticket_type: ticket_type)
      order1.calculate_amount

      order2 = Order.new(quantity: 2, ticket_type: ticket_type)
      order2.calculate_amount

      purchase_order.orders = [order1, order2]

      purchase_order.calculate_amount
      expect(purchase_order.total_amount_cents).to eq 80200
    end
  end

  describe '#currency_unit' do
    context 'no orders' do
      it 'returns default currency' do
        purchase_order = PurchaseOrder.new

        expect(purchase_order.currency_unit).to eq 'SGD'
      end
    end

    context 'has orders' do
      it 'returns currency of first order' do
        purchase_order = PurchaseOrder.new
        ticket_type = TicketType.new(currency_unit: 'BTC')
        purchase_order.orders << Order.new(ticket_type: ticket_type)

        expect(purchase_order.currency_unit).to eq 'BTC'
      end
    end
  end
end
