class OrdersMailer < ApplicationMailer
  def payment_successful(purchase_order)
    @purchase_order = purchase_order
    @event = purchase_order.event

    mail(to: @purchase_order.payer_email, subject: "[#{@event.name}] Ticket Purchase Order - #{@purchase_order.invoice_no} - #{@purchase_order.purchased_at.strftime('%e-%b-%Y')}")
  end

  def attendee_notification(purchase_order, ticket)
    @purchase_order = purchase_order
    @event = purchase_order.event
    @ticket = ticket
    @attendee = ticket.attendee

    logo_path = File.join(Rails.root, 'app', 'assets', 'images', 'krgh_facade_day.png')
    attachments.inline['krgh_facade_day.png'] = File.read(logo_path)

    mail(to: @ticket.attendee.email, subject: "[#{@event.name}] Event Ticket (#{@ticket.order.ticket_type.name}) - #{@purchase_order.purchased_at.strftime('%e-%b-%Y')}")
  end
end
