class AddCuttingToAttendees < ActiveRecord::Migration
  def change
    add_column :attendees, :cutting, :string
  end
end
