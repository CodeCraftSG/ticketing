class AddSizeToAttendee < ActiveRecord::Migration
  def change
    add_column :attendees, :size, :string
  end
end
