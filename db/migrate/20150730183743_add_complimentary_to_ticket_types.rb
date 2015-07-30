class AddComplimentaryToTicketTypes < ActiveRecord::Migration
  def change
    add_column :ticket_types, :complimentary, :boolean
  end
end
