class AddPayerInfoToPurchaseOrders < ActiveRecord::Migration
  def change
    add_column :purchase_orders, :payer_address, :text
    add_column :purchase_orders, :payer_email, :string
    add_column :purchase_orders, :payer_salutation, :string
    add_column :purchase_orders, :payer_first_name, :string
    add_column :purchase_orders, :payer_last_name, :string
    add_column :purchase_orders, :payer_country, :string
    add_column :purchase_orders, :raw_payment_details, :text
  end
end
