class OrdersController < ApplicationController
  before_filter :set_purchase_order, except: [:checkout]

  def checkout
    if params[:payment_token]
      @purchase_order = PurchaseOrder.find_by(payment_token: params[:payment_token])
    else
      build_purchase_order
    end

    if @purchase_order.success?
      return redirect_to attendees_order_path(@purchase_order.payment_token), flash: {notice: "Payment Received!"}
    end

    begin
      PurchaseOrder.transaction do
        if @purchase_order.needs_payment_info_early?
          payer_info_params.each do |k,v|
            @purchase_order.send("#{k}=".to_sym, v)
          end
        end
        @purchase_order.save!

        if @purchase_order.total_amount_cents == 0
          @purchase_order.update(payer_info_params.merge(status: 'success', purchased_at: Time.now, invoice_no: @purchase_order.auto_invoice_no))
          OrdersMailer.payment_successful(@purchase_order).deliver_later
          return redirect_to attendees_order_path(@purchase_order.payment_token), flash: {success: "Order Received!"}
        elsif @purchase_order.currency_unit == 'SGD'
          if params[:stripeToken].present?
            charge_details = {currency: @purchase_order.currency_unit,
                              description: @purchase_order.description,
                              statement_descriptor: @purchase_order.auto_invoice_no,
                              email: stripe_params[:payer_email],
                              order_id: @purchase_order.auto_invoice_no
            }
            response = STRIPE_GATEWAY.purchase(@purchase_order.total_amount_cents, params[:stripeToken], charge_details)
            if response.success?
              @purchase_order.update(stripe_params.merge(status: 'success', purchased_at: Time.now, invoice_no: @purchase_order.auto_invoice_no))
              OrdersMailer.payment_successful(@purchase_order).deliver_later
              return redirect_to attendees_order_path(@purchase_order.payment_token), flash: {success: "Order Received!"}
            end
          else
            response = EXPRESS_GATEWAY.setup_purchase(@purchase_order.total_amount_cents,
                                                      ip: request.remote_ip,
                                                      return_url: success_order_url(@purchase_order.payment_token),
                                                      cancel_return_url: cancel_order_url(@purchase_order.payment_token),
                                                      currency: @purchase_order.currency_unit,
                                                      allow_guest_checkout: true,
                                                      items: [@purchase_order.build_payment_params]
            )
            return redirect_to EXPRESS_GATEWAY.redirect_url_for(response.token)
          end
        elsif @purchase_order.currency_unit == 'BTC'
          begin
            express_token = SecureRandom.hex(5)
            return_address = complete_bitcoin_url(@purchase_order.payment_token, secret:express_token)
            input_address = BlockchainService.receive(return_address)
            raw_payment_details = {
                input_address: input_address,
                return_address: return_address
            }.to_json
            @purchase_order.update(payer_info_params.merge(express_token:express_token, raw_payment_details:raw_payment_details))
            OrdersMailer.payment_started(@purchase_order).deliver_later
            return redirect_to payment_bitcoin_path(@purchase_order.payment_token)
          rescue => e
            return redirect_to order_path(@purchase_order.payment_token), flash: {error: e.message}
          end
        end
      end
    rescue => e
      Rails.logger.error "Exception: Unable to save payment (#{e.message}) for #{params}"
      flash.now[:error] = e.message
      render 'ticketings/review_order'
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
      Attendee.transaction do
        @purchase_order.orders.each do |order|
          order.tickets.delete_all
          (1..order.ticket_entitlement).each do |i|
            person = params[:order][order.id.to_s][i.to_s]
            attendee = Attendee.create!(
                first_name: person[:first_name],
                last_name: person[:last_name],
                email: person[:email],
                twitter: person[:twitter].gsub(/[@]/,''),
                github: person[:github],
                cutting: person[:cutting],
                size: person[:size]
            )
            ticket = Ticket.new(attendee: attendee)
            ticket.document = person[:document] if order.ticket_type.needs_document? && person[:document].present?
            order.tickets << ticket
          end
          order.save!
        end
      end
      @purchase_order.orders.each do |order|
        order.send_attendee_notifications
      end
      redirect_to completed_order_path(@purchase_order.payment_token)
    rescue => e
      Rails.logger.error "Exception: Unable to update attendee details for #{@purchase_order.payment_token}. Error: #{e.message}"
      flash[:error] = e.message
      render :attendee_particulars
    end
  end

  def completed
  end

  private

  def payer_info_params
    params.require(:purchase_order).permit(:payer_first_name, :payer_last_name, :payer_email)
  end

  def set_purchase_order
    @purchase_order = PurchaseOrder.find_by(payment_token: params[:id])
  end

  def stripe_params
    payer_info = params.permit(:stripeToken, :stripeEmail, :stripeBillingName, :stripeBillingAddressLine1, :stripeBillingAddressZip,
                  :stripeBillingAddressState, :stripeBillingAddressCity, :stripeBillingAddressCountry
                 )

    { express_token: payer_info[:stripeToken],
      notes: 'Stripe Payment',
      payer_address: {
          address1:payer_info[:stripeBillingAddressLine1],
          postal_code:payer_info[:stripeBillingAddressZip],
          state:payer_info[:stripeBillingAddressState],
          city:payer_info[:stripeBillingAddressCity],
          country:payer_info[:stripeBillingAddressCountry]
        }.to_json,
      payer_email: payer_info[:stripeEmail],
      payer_first_name: payer_info[:stripeBillingName],
      payer_country: payer_info[:stripeBillingAddressCountry]
    }
  end
end
