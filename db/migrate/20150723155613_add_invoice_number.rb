class AddInvoiceNumber < ActiveRecord::Migration
  def change
    add_column :purchase_orders, :invoice_no, :string
  end
end
