class TicketingsController < ApplicationController
  before_filter :fetch_event
  before_filter :fetch_ticket_types
  CONF_ID = 1

  def index
    @orders = {}
    @ticket_types.each do |t|
      qty = params[:ticket_type][t.id.to_s].try('[]', :qty) if params[:ticket_type]
      qty = 0 if qty.nil? || qty.empty?
      @orders[t.id] = qty
    end

    #clicked on submit button
    if params[:next]
      session[:coupon_code] = coupon_code if coupon_code
      redirect_to review_order_ticketings_path(event_id: @event.id, orders: @orders, code: coupon_code)
    end
  end

  def review_order
    @purchase_orders = []

    @ticket_types.each do |ticket_type|
      qty = orders_param[ticket_type.id.to_s].try(:to_i) || 0
      if qty > 0
        amount_in_cents = qty * ticket_type.price * 100
        @purchase_orders << Order.new(ticket_type:ticket_type, quantity:qty, total_amount_cents: amount_in_cents)
      end
    end

    @total_amount = @purchase_orders.inject(0){|sum, order| sum + order.total_amount}
  end

  private

  def fetch_ticket_types
    @ticket_types = @event.ticket_types.tickets_available(code: coupon_code)
  end

  def fetch_event
    @event = Event.find(event_id)
  end

  def coupon_code
    params[:code]
  end

  def event_id
    params[:event_id] || CONF_ID
  end

  def orders_param
    params.require(:orders)
  end
end
