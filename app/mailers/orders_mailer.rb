class OrdersMailer < ApplicationMailer
  def payment_successful(purchase_order)
    @purchase_order = purchase_order
    @event = purchase_order.event

    mail(to: @purchase_order.payer_email, subject: "[PHPConf.Asia] Invoice #{@purchase_order.invoice_no} - Event Tickets - #{@purchase_order.purchased_at.strftime('%a, %e-%b-%Y')}")
  end
end
