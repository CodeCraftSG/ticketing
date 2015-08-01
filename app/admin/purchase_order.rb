ActiveAdmin.register PurchaseOrder do
  menu priority: 3

  config.batch_actions = false

  actions :all, except: [:edit, :update, :destroy]

  filter :event
  filter :payment_token
  filter :purchased_at
  filter :express_token
  filter :payer_first_name
  filter :payer_last_name
  filter :payer_email
  filter :status, as: :check_boxes, collection: PurchaseOrder.statuses

  index do
    column :event
    column('Payment Token / Invoice') do |po|
      if po.invoice_no.present?
        po.invoice_no
      else
        po.payment_token
      end
    end
    column :created_at
    column :purchased_at
    column 'Payer' do |po|
      payer_info = []
      payer_info << po.transaction_id || ''
      payer_info << po.express_token || ''
      payer_info << "#{po.payer_first_name} #{po.payer_last_name}<br/>(#{po.payer_email})" if po.payer_email.present?

      payer_info.join('<br/>').html_safe
    end
    column 'Amount' do |po|
      number_to_currency po.total_amount, unit: 'SGD$'
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

  show do
    attributes_table do
      row :event
      row :invoice_no
      row :created_at
      row :purchased_at
      row('Transaction ID') do |po|
        po.transaction_id
      end
      row :payment_token
      row('Payer') do |po|
        "#{po.payer_first_name} #{po.payer_last_name} <br/>(<a href='mailto:#{po.payer_email}'>#{po.payer_email}</a>)".html_safe
      end
      row :express_token
      row('Amount'){ |t| number_to_currency(t.total_amount, unit: 'SGD$') }
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
        column('Total') { |o| number_to_currency o.total_amount, unit: 'SGD$' }
      end
    end

    panel "Attendees" do
      table_for purchase_order.tickets do
        column('Ticket') { |t| t.order.ticket_type.name }
        column('First name') { |t| t.attendee.first_name }
        column('Last name') { |t| t.attendee.last_name }
        column('Email') { |t| t.attendee.email }
        column('Size') { |t| t.attendee.size }
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
end
