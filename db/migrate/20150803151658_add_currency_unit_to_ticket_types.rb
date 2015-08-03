class AddCurrencyUnitToTicketTypes < ActiveRecord::Migration
  def self.up
    add_column :ticket_types, :currency_unit, :string, default: 'SGD'
    TicketType.all.each do |t|
      t.update(currency_unit: 'SGD')
    end
  end

  def self.down
    remove_column :ticket_types, :currency_unit
  end
end
