class CreatePurchaseOrders < ActiveRecord::Migration
  def change
    create_table :purchase_orders do |t|
      t.integer :total_amount_cents
      t.datetime :purchased_at
      t.string :ip
      t.string :express_token
      t.string :express_payer_id
      t.text :notes
      t.integer :status
      t.timestamps
    end
  end
end
