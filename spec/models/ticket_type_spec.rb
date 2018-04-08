require 'rails_helper'

RSpec.describe TicketType, type: :model do
  describe 'associations' do
    it { should belong_to(:event) }
    it { should have_many(:orders) }
    it { should have_many(:tickets).through(:orders) }
    it { should have_many(:attendees).through(:tickets) }
  end

  describe 'scope' do
    let(:active) { true }
    let(:hidden) { false }
    let(:code) { 'code1' }
    let!(:valid) { FactoryBot.create :ticket_type, active: active, hidden: hidden, code: code }

    shared_examples_for 'valid ticket_type' do |action|
      it "returns valid items for #{action}" do
        expect(TicketType.send(action)).to include valid
      end
    end

    describe '.active' do
      it_behaves_like 'valid ticket_type', :active

      it 'does not return active ticket_types' do
        inactive = FactoryBot.create :ticket_type, active:false

        expect(TicketType.active).to_not include inactive
      end
    end

    describe '.visible' do
      it_behaves_like 'valid ticket_type', :visible

      it 'does not return not visible ticket_types' do
        not_visible = FactoryBot.create :ticket_type, hidden:true

        expect(TicketType.visible).to_not include not_visible
      end
    end

    describe '.with_code' do
      it 'returns ticket_types with correct code' do
        not_visible = FactoryBot.create :ticket_type, code: 'code2'

        expect(TicketType.with_code('code1')).to include valid
        expect(TicketType.with_code('code1')).to_not include not_visible
      end
    end
  end

  describe '#available?' do
    let(:today) { Date.today.beginning_of_day }
    let!(:available) { FactoryBot.create :ticket_type, sale_starts_at: 1.day.ago, sale_ends_at: 5.days.from_now }
    let!(:not_available) { FactoryBot.create :ticket_type, sale_starts_at: 5.day.ago, sale_ends_at: 1.day.ago }

    context 'sale started and not ending yet' do
      it 'returns true' do
        ticket_type = FactoryBot.build :ticket_type, sale_starts_at: 1.day.ago, sale_ends_at: 5.days.from_now
        expect(ticket_type.available?(today)).to be
      end
    end

    context 'sale started but ended' do
      it 'returns false' do
        ticket_type = FactoryBot.create :ticket_type, sale_starts_at: 5.day.ago, sale_ends_at: 1.day.ago
        expect(ticket_type.available?(today)).to_not be
      end
    end

    context 'sale not started yet' do
      it 'returns false' do
        ticket_type = FactoryBot.build :ticket_type, sale_starts_at: 5.day.from_now, sale_ends_at: 10.days.from_now
        expect(ticket_type.available?(today)).to_not be
      end
    end
  end

  describe '.tickets_available' do
    let!(:active) { FactoryBot.create :ticket_type, name: 'Active type', active:true, hidden:false, sequence:1 }
    let!(:hidden_and_coded) { FactoryBot.create :ticket_type, name: 'Hidden and coded', active:true, hidden:true, code:discount_code, sequence:0 }
    let!(:inactive) { FactoryBot.create :ticket_type, name: 'Inactive', active: false, hidden:false, sequence: 2 }

    let(:discount_code) { nil }
    let(:do_action) { TicketType.tickets_available(code: discount_code) }

    describe 'with reference date' do
      it 'returns valid ticket_types' do
        expect(do_action).to contain_exactly active
      end

      context 'with discount code' do
        let(:discount_code) { 'code1' }

        it 'returns valid ticket_types and coded ticket' do
          expect(do_action).to contain_exactly active, hidden_and_coded
        end

        it 'return coded ticket_type first' do
          expect(do_action.first).to eq hidden_and_coded
        end

        context 'wrong code' do
          let(:do_action) { TicketType.tickets_available(code: 'code2') }

          it 'returns valid ticket_types only' do
            expect(do_action).to contain_exactly active
          end
        end
      end
    end

    context 'standalone ticket' do
      let(:sponsor_code) { 'sponsor' }
      let!(:standalone) { FactoryBot.create :ticket_type, name: 'Sponsor ticket', code:sponsor_code, active: true, hidden: true, standalone: true, sequence: 2 }
      let(:do_action) { TicketType.tickets_available(code: sponsor_code) }

      it 'returns only standalone ticket' do
        expect(do_action).to contain_exactly standalone
      end
    end
  end
end
