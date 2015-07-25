class AddEventIdToPurchaseOrders < ActiveRecord::Migration
  def change
    add_reference :purchase_orders, :event, index: true, foreign_key: true
  end
end
