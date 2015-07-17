class CreateAttendees < ActiveRecord::Migration
  def change
    create_table :attendees do |t|
      t.string :first_name
      t.string :last_name
      t.string :id_number
      t.string :email
      t.string :twitter

      t.timestamps null: false
    end
  end
end
