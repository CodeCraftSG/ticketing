class AddPaymenTokenToPurchaseOrders < ActiveRecord::Migration
  def change
    add_column :purchase_orders, :payment_token, :string, index: true
  end
end
