class TicketingsController < ApplicationController
  CONF_ID = 1

  def index
    @event = event
    @ticket_types = @event.ticket_types.tickets_available(code: discount_code)

    @orders = {}
    @ticket_types.each do |t|
      qty = params[:ticket_type][t.id.to_s].try('[]', :qty) if params[:ticket_type]
      qty = 0 if qty.nil? || qty.empty?
      @orders[t.id] = qty
    end
  end

  private

  def event
    Event.find(CONF_ID)
  end

  def discount_code
    params[:code]
  end
end
