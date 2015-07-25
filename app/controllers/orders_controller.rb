class OrdersController < ApplicationController
  before_filter :set_purchase_order, except: [:express_checkout]

  def express_checkout
    if params[:payment_token]
      @purchase_order = PurchaseOrder.find_by(payment_token: params[:payment_token])
    else
      build_purchase_order
    end

    if @purchase_order.success?
      return redirect_to attendees_order_path(@purchase_order.payment_token), flash: {notice: "Payment Received!"}
    end

    if @purchase_order.save
      response = EXPRESS_GATEWAY.setup_purchase(@purchase_order.total_amount_cents,
        ip: request.remote_ip,
        return_url: success_order_url(@purchase_order.payment_token),
        cancel_return_url: cancel_order_url(@purchase_order.payment_token),
        currency: PurchaseOrder::CURRENCY,
        allow_guest_checkout: true,
        items: [@purchase_order.build_payment_params]
      )

      redirect_to EXPRESS_GATEWAY.redirect_url_for(response.token)
    else
      Rails.logger.error "Exception: Unable to save payment for #{params}"
      redirect_to request.referer, flash: {error: 'Unable to initiate payment.'}
    end
  end

  def show
  end

  def success
    begin
      @purchase_order.purchase(params[:token])
      redirect_to attendees_order_path(@purchase_order.payment_token), flash: {success: "Payment Received!"}
    rescue => e
      redirect_to order_path(@purchase_order.payment_token), flash: {error: e.message}
    end
  end

  def cancel
    @purchase_order.cancelled!
    Rails.logger.error "Exception: Payment Cancelled for #{@purchase_order.payment_token}"

    redirect_to order_path(@purchase_order.payment_token), flash: {error: "Order was cancelled."}
  end

  def attendee_particulars
    unless @purchase_order.success?
      Rails.logger.error "Exception: Unable to start update of attendee details for #{@purchase_order.payment_token} as payment was not successful."
      return redirect_to ticketings_path, flash: {error: "Invalid purchase order. Please try again."}
    end
    if @purchase_order.attendees.count > 0
      Rails.logger.error "Exception: Unable to start update of attendee details for #{@purchase_order.payment_token} as Attendee details already updated."
      return redirect_to ticketings_path, flash: {error: "Attendee details has already been added. Please email admin@phpconf.asia if you think this is in error."}
    end
  end

  def update_attendee_particulars
    begin
      @purchase_order.orders.each do |order|
        order.tickets.delete_all
        (1..order.quantity).each do |i|
          person = params[:order][order.id.to_s][i.to_s]
          attendee = Attendee.where(first_name: person[:first_name],
                                    last_name: person[:last_name],
                                    email: person[:email],
                                    twitter: person[:twitter],
                                    github: person[:github],
                                    size: person[:size]
                                   ).first_or_create{ |a| a.size = person[:size] }
          order.tickets << Ticket.new(attendee: attendee)
        end
        order.save!
      end
      redirect_to completed_order_path(@purchase_order.payment_token)
    rescue => e
      Rails.logger.error "Exception: Unable to update attendee details for #{@purchase_order.payment_token}. Error: #{e.message}"
      redirect_to ticketings_path, flash: {error: e.message}
    end
  end

  def completed
  end

  private

  def set_purchase_order
    @purchase_order = PurchaseOrder.find_by(payment_token: params[:id])
  end
end
