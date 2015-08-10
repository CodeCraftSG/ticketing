require 'rails_helper'

RSpec.describe Ticket, type: :model do
  describe 'associations' do
    it{ should belong_to(:order) }
    it{ should belong_to(:attendee) }
  end
end
