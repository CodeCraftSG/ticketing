module OrderHelper
  def price_with_currency(price)
    number_to_currency(price, unit: 'SGD$')
  end
end
