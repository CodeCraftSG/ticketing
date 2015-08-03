module OrderHelper
  def price_with_currency(price, unit='SGD$')
    number_to_currency(price, unit: unit)
  end
end
