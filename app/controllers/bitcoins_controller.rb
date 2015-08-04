class BitcoinsController < ApplicationController
  before_filter :set_purchase_order

  def payment
    @input_address = @purchase_order.transaction_details_hash[:input_address]
  end

  def complete_payment
    begin
      raise 'Received Test Mode' if params[:test]
      raise 'Invalid purchase order ID' if @purchase_order.nil?
      raise 'Invalid secret for the Purchase Order' if @purchase_order.express_token != payment_params[:secret]
      raise 'Invalid destination wallet' if payment_params[:destination_address] != ENV["BITCOIN_WALLET"]
      raise 'Not enough confirmations' if payment_params[:confirmations].to_i < 2

      if @purchase_order.update(
          status: 'success',
          purchased_at: Time.now,
          invoice_no: @purchase_order.auto_invoice_no,
          raw_payment_details: {
                      'TransactionId' => payment_params[:transaction_hash],
                      value: ( payment_params[:value].to_f / 100000000),
                      input_transaction_hash: payment_params[:input_transaction_hash],
                      input_address: payment_params[:input_address]
                  }.to_json
      )
        OrdersMailer.payment_successful(@purchase_order).deliver_later
        return render text:'*ok*'
      end
    rescue => e
      Rails.logger.error "Exception: Unable to complete BTC payment: #{e.message} / Params: #{payment_params}"
      return render text: e.message
    end
    render text:''
  end

  private

  def payment_params
    params.permit(:id, :secret, :value, :input_address, :confirmations, :transaction_hash, :input_transaction_hash, :destination_address)
  end

  def set_purchase_order
    @purchase_order = PurchaseOrder.find_by(payment_token: params[:id])
  end
end
