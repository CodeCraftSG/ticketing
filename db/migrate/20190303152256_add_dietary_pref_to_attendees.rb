class AddDietaryPrefToAttendees < ActiveRecord::Migration
  def change
    add_column :attendees, :dietary_pref, :string
  end
end
