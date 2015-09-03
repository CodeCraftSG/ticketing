ActiveAdmin.register PurchaseOrder do
  menu priority: 3

  permit_params :event_id, :invoice_no, :purchased_at, :payment_token, :ip,
    :payer_first_name, :payer_last_name, :payer_email, :payer_address, :payer_country, :status, :notes,
    orders_attributes: [:id, :purchase_order_id, :ticket_type_id, :quantity, :total_amount_cents, :_destroy]

  # config.batch_actions = false
  # actions :all, except: [:new, :edit, :update, :destroy]

  filter :event
  filter :payment_token
  filter :purchased_at
  filter :express_token
  filter :payer_first_name
  filter :payer_last_name
  filter :payer_email
  filter :status, as: :check_boxes, collection: PurchaseOrder.statuses

  controller do
    def new
      @purchase_order = PurchaseOrder.new
      @purchase_order.event = Event.first
      @purchase_order.purchased_at = Date.today
      @purchase_order.status = :pending
    end

    def create
      params['purchase_order']['ip'] = request.remote_ip
      super
    end
  end

  index do
    selectable_column
    column :event
    column('Payment Token / Invoice') do |po|
      if po.invoice_no.present?
        po.invoice_no
      else
        po.payment_token
      end
    end
    column :created_at
    column :ip
    column :purchased_at
    column 'Payer' do |po|
      payer_info = []
      payer_info << po.transaction_id if po.transaction_id
      payer_info << po.express_token if po.express_token
      payer_info << "#{po.payer_first_name} #{po.payer_last_name}<br/>(#{po.payer_email})" if po.payer_email.present?

      payer_info.join('<br/>').html_safe
    end
    column 'Amount' do |po|
      number_to_currency po.total_amount, unit: po.currency_unit + '$'
    end
    column 'Attendees' do |po|
      po.attendees.count
    end
    column 'Status' do |po|
      status_txt = case po.status
                     when 'success'
                       'ok'
                     when 'pending'
                       'warning'
                     when 'cancelled'
                       'error'
                   end
      status_tag po.status, status_txt
    end
    actions
  end

  form do |f|
    tabs do
      tab 'Details' do
        inputs 'Purchase Details' do
          f.input :event
          f.input :invoice_no
          f.input :purchased_at, as: :datepicker
          f.input :status, as: :select, collection: PurchaseOrder.statuses.keys
        end
        inputs 'Other Details' do
          f.input :notes
        end
      end
      tab 'Payer' do
        inputs 'Payer Details' do
          f.input :payer_first_name, label: 'First name'
          f.input :payer_last_name, label: 'Last name'
          f.input :payer_email, label: 'Email'
          f.input :payer_country, label: 'Country', priority_countries: ['SG'], include_blank: true
          f.input :payer_address, label: 'Address'
        end
      end
      tab 'Orders' do
        f.inputs do
          f.has_many :orders, new_record: 'New Order', allow_destroy: true do |o|
            o.input :ticket_type_id, as: :select, collection: TicketType.all
            o.input :quantity
          end
        end
      end
    end
    f.actions
  end

  show do
    attributes_table do
      row :event
      row :invoice_no
      row :created_at
      row :ip
      row :purchased_at
      row('Transaction ID') do |po|
        po.transaction_id
      end
      row :payment_token
      row('Payer') do |po|
        "#{po.payer_first_name} #{po.payer_last_name} <br/>(<a href='mailto:#{po.payer_email}'>#{po.payer_email}</a>)".html_safe
      end
      row :express_token
      row('Amount'){ |po| number_to_currency(po.total_amount, unit: po.currency_unit + '$') }
      row('Address') do |po|
        if po.payer_address.present?
          address = JSON.parse(po.payer_address)
          address.map{|v| "<b>#{v.first.capitalize}</b>: #{v.last}" if v.last.present? }.compact.join('<br/>').html_safe
        end
      end
      row('Status') do |po|
        status_txt = case po.status
                       when 'success'
                         'ok'
                       when 'pending'
                         'warning'
                       when 'cancelled'
                         'error'
                     end
        status_tag po.status, status_txt
      end
    end

    panel "Order Items" do
      table_for purchase_order.orders do
        column('Type') { |o| o.ticket_type.name }
        column('Quantity') { |o| o.quantity }
        column('Total') { |o| number_to_currency o.total_amount, unit: o.ticket_type.currency_unit + '$' }
      end
    end

    panel "Attendees" do
      table_for purchase_order.tickets do
        column('Ticket') { |t| t.order.ticket_type.name }
        column('First name') { |t| t.attendee.first_name }
        column('Last name') { |t| t.attendee.last_name }
        column('Email') { |t| t.attendee.email }
        column('Size') { |t| "#{t.attendee.cutting} #{t.attendee.size}" }
        column('Twitter') { |t| t.attendee.twitter }
        column('Github') { |t| t.attendee.github }
        column('Document') do |t|
          if t.order.ticket_type.needs_document?
            if t.document.present?
              status_tag('Uploaded', 'ok')
            else
              status_tag('Unavailable', 'error')
            end
          else
            '-'
          end
        end
      end
    end
  end

  sidebar :notification, only: :show do
    div style:'text-align:center;padding-bottom: 10px;' do
      button_to 'Resend email to Payer', admin_purchase_order_path(resource), method: 'get'
    end
    div style:'text-align:center;' do
      button_to 'Resend email to Attendees', admin_purchase_order_path(resource), method: 'get'
    end
  end
end
