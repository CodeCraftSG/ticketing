class TicketingsController < ApplicationController
  def index
    @orders = {}
    @ticket_types.each do |t|
      qty = params[:ticket_type][t.id.to_s].try('[]', :qty) if params[:ticket_type]
      qty = 1 if qty.nil? && t.standalone?
      qty = 0 unless qty.present?

      @orders[t.id] = qty
    end

    #clicked on submit button
    if params[:next]
      session[:coupon_code] = coupon_code if coupon_code
      redirect_to review_order_ticketings_path(event_id: @event.id, orders: @orders, code: coupon_code)
    end
  end

  def review_order
    build_purchase_order
  end
end
