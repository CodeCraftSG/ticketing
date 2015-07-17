class CreateTicketTypes < ActiveRecord::Migration
  def change
    create_table :ticket_types do |t|
      t.references :event, index: true, foreign_key: true
      t.string :name
      t.text :description
      t.decimal :strikethrough_price, precision: 5, scale: 2
      t.decimal :price, precision: 5, scale: 2
      t.integer :quota
      t.boolean :hidden
      t.string :code
      t.boolean :active
      t.datetime :sale_starts_at
      t.datetime :sale_ends_at

      t.timestamps null: false
    end
  end
end
