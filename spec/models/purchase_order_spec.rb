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

  describe '#needs_payer_info_early?' do
    let!(:order) { FactoryGirl.build(:order, ticket_type: ticket_type, quantity: 1).calculate_amount }
    let(:orders){ [ order ] }
    let(:purchase_order) { FactoryGirl.build :purchase_order, orders: orders }

    context 'bitcoin' do
      let(:ticket_type) { FactoryGirl.build :ticket_type, standalone: true, price: 1.0, currency_unit: 'BTC' }

      it 'returns true' do
        expect(purchase_order.needs_payment_info_early?).to be
      end
    end

    context 'complimentary' do
      let!(:ticket_type) { FactoryGirl.build :ticket_type, complimentary: true, price: 0.0 }

      it 'returns true' do
        expect(purchase_order.needs_payment_info_early?).to be
      end
    end
  end

  describe '#description' do
    before do
      subject.calculate_amount
    end

    context 'no orders yet' do
      subject{ FactoryGirl.build :purchase_order, orders: [] }

      it 'returns empty string if no orders found' do
        expect(subject.description).to eq ''
      end
    end

    context 'has 1 order' do
      let(:ticket_type) { FactoryGirl.create :ticket_type, name: 'Early Bird', price: 200.50, entitlement: 2 }
      let(:order) { FactoryGirl.create :order, ticket_type: ticket_type, quantity: 2 }
      subject{ FactoryGirl.create :purchase_order, orders: [order] }

      it 'returns description for one order' do
        expect(subject.description).to eq "Early Bird (4 tickets)"
      end
    end

    context 'has more than order' do
      let(:early_bird) { FactoryGirl.create :ticket_type, name: 'Early Bird', price: 200.50, entitlement: 2 }
      let(:student) { FactoryGirl.create :ticket_type, name: 'Student', price: 90, entitlement: 1 }

      let(:order1) { FactoryGirl.create :order, ticket_type: early_bird, quantity: 2 }
      let(:order2) { FactoryGirl.create :order, ticket_type: student, quantity: 1 }
      subject{ FactoryGirl.create :purchase_order, orders: [order1, order2] }

      it 'returns description for one order' do
        expect(subject.description).to eq "Early Bird (4 tickets), Student (1 tickets)"
      end
    end
  end

  describe 'entitlements' do
    let(:early_bird) { FactoryGirl.create :ticket_type, name: 'Early Bird', price: 200.50, entitlement: 2 }
    let(:student) { FactoryGirl.create :ticket_type, name: 'Student', price: 90, entitlement: 1 }

    let(:order1) { FactoryGirl.create :order, ticket_type: early_bird, quantity: 2 }
    let(:order2) { FactoryGirl.create :order, ticket_type: student, quantity: 1 }
    subject{ FactoryGirl.create :purchase_order, orders: [order1, order2] }

    it 'returns 5' do
      expect(subject.entitlements).to eq 5
    end
  end
end
