class OrdersController < ApplicationController
  before_filter :set_purchase_order, except: [:express_checkout]

  def express_checkout
    if params[:payment_token]
      @purchase_order = PurchaseOrder.find_by(payment_token: params[:payment_token])
    else
      build_purchase_order
    end

    if @purchase_order.success?
      return redirect_to attendees_ticketing_path(@purchase_order.payment_token), flash: {notice: "Payment Received!"}
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
      redirect_to attendees_ticketing_path(@purchase_order.payment_token), flash: {notice: "Payment Received!"}
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
    render text: params
  end

  private

  def set_purchase_order
    @purchase_order = PurchaseOrder.find_by(payment_token: params[:id])
  end
end
