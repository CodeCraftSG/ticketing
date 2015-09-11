class PopulatePublicIdInAttendees < ActiveRecord::Migration
  def self.up
    Attendee.all.each do |a|
      a.cutting = 'Men size' if a.cutting.nil?
      a.auto_public_id
      a.save!
    end
  end

  def self.down
  end
end
