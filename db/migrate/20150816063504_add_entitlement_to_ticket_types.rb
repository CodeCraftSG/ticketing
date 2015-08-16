class AddEntitlementToTicketTypes < ActiveRecord::Migration
  def change
    add_column :ticket_types, :entitlement, :integer, default: 1
  end
end
