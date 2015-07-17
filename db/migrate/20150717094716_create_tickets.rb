class CreateTickets < ActiveRecord::Migration
  def change
    create_table :tickets do |t|
      t.references :order, index: true, foreign_key: true
      t.references :attendee, index: true, foreign_key: true
      t.text :notes

      t.timestamps null: false
    end
  end
end
