class ChangePrecisionOfPrices < ActiveRecord::Migration
  def change
    change_table :ticket_types do |t|
      t.change :price, :decimal, precision: 10, scale: 2
      t.change :strikethrough_price, :decimal, precision: 10, scale: 2
    end
  end
end
