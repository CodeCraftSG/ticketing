class AddDocumentToTickets < ActiveRecord::Migration
  def change
    add_column :tickets, :document, :string
  end
end
