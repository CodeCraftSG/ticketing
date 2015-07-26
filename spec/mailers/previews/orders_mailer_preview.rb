class OrdersMailerPreview < ActionMailer::Preview
  def payment_successful
    purchase_order = PurchaseOrder.last
    OrdersMailer.payment_successful(purchase_order)
  end

  def attendee_notification
    purchase_order = PurchaseOrder.last
    ticket = purchase_order.orders.first.tickets.first
    OrdersMailer.attendee_notification(purchase_order, ticket)
  end
end
