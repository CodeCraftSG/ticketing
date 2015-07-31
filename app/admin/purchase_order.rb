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
  filter :status


  index do
    column :event
    column :payment_token
    column :purchased_at
    column 'Payer' do |po|
      "#{po.payer_first_name} #{po.payer_last_name} <br/>(#{po.payer_email})".html_safe
    end
    column :express_token
    column 'Amount' do |po|
      number_to_currency po.total_amount, unit: 'SGD$'
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
      row :payment_token
      row :purchased_at
      row('Payer') do |po|
        "#{po.payer_first_name} #{po.payer_last_name} <br/>(<a href='mailto:#{po.payer_email}'>#{po.payer_email}</a>)".html_safe
      end
      row :express_token
      row('Amount'){ |t| number_to_currency(t.total_amount, unit: 'SGD$') }
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
      end
    end
  end
end
