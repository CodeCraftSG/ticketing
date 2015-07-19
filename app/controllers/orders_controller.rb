class OrdersController < ApplicationController
  def express_checkout
    build_purchase_order
    puts @purchase_order.inspect
    render text: params
  end
end
