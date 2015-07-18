class AddSequenceToTicketType < ActiveRecord::Migration
  def change
    add_column :ticket_types, :sequence, :integer, default: 0, null: false
  end
end
