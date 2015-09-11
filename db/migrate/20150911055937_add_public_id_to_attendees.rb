class AddPublicIdToAttendees < ActiveRecord::Migration
  def change
    add_column :attendees, :public_id, :string, index: true, null: false, default: 'NA'
  end
end
