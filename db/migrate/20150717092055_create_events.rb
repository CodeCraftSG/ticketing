class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :name
      t.date :start_date
      t.date :end_date
      t.string :daily_start_time
      t.string :daily_end_time
      t.text :description
      t.boolean :active

      t.timestamps null: false
    end
  end
end
