class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.references :ticket_type, index: true, foreign_key: true
      t.integer :quantity
      t.integer :total_amount_cents
      t.string :ip
      t.string :express_token
      t.string :express_payer_id
      t.text :notes
      t.datetime :purchased_at

      t.timestamps null: false
    end
  end
end
