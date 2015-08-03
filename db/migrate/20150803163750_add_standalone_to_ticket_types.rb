class AddStandaloneToTicketTypes < ActiveRecord::Migration
  def change
    add_column :ticket_types, :standalone, :boolean, default: false
  end
end
