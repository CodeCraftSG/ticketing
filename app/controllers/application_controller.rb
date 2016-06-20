class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_filter :set_paper_trail_whodunnit
  before_filter :fetch_event
  before_filter :fetch_ticket_types
  helper_method :coupon_code

  CONF_ID = 1

  protected

  def fetch_event
    @event = Event.find(event_id)
  end

  def fetch_ticket_types
    @ticket_types = @event.ticket_types.tickets_available(code: coupon_code)
  end

  def build_purchase_order
    @purchase_order = PurchaseOrder.new(ip: request.remote_ip, status: :pending, event: @event)

    @ticket_types.each do |ticket_type|
      qty = 0
      if ticket_type.restrict_quantity_per_order? && ticket_type.quantity_per_order > 0
        qty = ticket_type.quantity_per_order
      elsif orders_param[ticket_type.id.to_s].present?
        qty = orders_param[ticket_type.id.to_s].try(:to_i) || 0
      end
      if qty > 0
        @purchase_order.orders << Order.new(ticket_type:ticket_type, quantity:qty).calculate_amount
      end
    end

    @purchase_order.calculate_amount
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

  def user_for_paper_trail
    admin_user_signed_in? ? current_admin_user.try(:id) : 'Public user'
  end
end
