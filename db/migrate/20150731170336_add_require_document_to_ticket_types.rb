class AddRequireDocumentToTicketTypes < ActiveRecord::Migration
  def change
    add_column :ticket_types, :needs_document, :boolean
  end
end
