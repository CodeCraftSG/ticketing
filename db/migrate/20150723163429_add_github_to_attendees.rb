class AddGithubToAttendees < ActiveRecord::Migration
  def change
    add_column :attendees, :github, :string
  end
end
