class AddRestrictQuantityToTicketTypes < ActiveRecord::Migration
  def change
    add_column :ticket_types, :restrict_quantity_per_order, :boolean
    add_column :ticket_types, :quantity_per_order, :integer, default: 0, nil: false
  end
end
