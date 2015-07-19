class AlterOrdersTable < ActiveRecord::Migration
  def change
    add_reference :orders, :purchase_order, index: true, foreign_key: true
    remove_column :orders, :purchased_at, :datetime
    remove_column :orders, :ip, :string
    remove_column :orders, :express_token, :string
    remove_column :orders, :express_payer_id, :string
    remove_column :orders, :notes, :text
  end
end
