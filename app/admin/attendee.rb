ActiveAdmin.register Attendee do
  menu priority: 6

  # config.batch_actions = false

  actions :all

  filter :first_name
  filter :last_name
  filter :email
  filter :twitter
  filter :github

  index do
    selectable_column
    column :first_name
    column :last_name
    column :email
    column :cutting
    column :size
    column :twitter
    column :github
    column 'Ticket' do |r|
      r.tickets&.first&.order&.ticket_type&.name
    end
    column 'Invoice No.' do |r|
      r.tickets&.first&.order&.purchase_order&.invoice_no
    end
    column 'Status' do |r|
      status_txt = case r.tickets&.first&.order&.purchase_order&.status
                     when 'success'
                       'ok'
                     when 'pending'
                       'warning'
                     when 'cancelled'
                       'error'
                   end
      status_tag r.tickets&.first&.order&.purchase_order&.status, status_txt
    end
    actions
  end

  csv do
    column :first_name
    column :last_name
    column :email
    column :cutting
    column :size
    column :twitter
    column :github
    column 'Ticket' do |r|
      r.tickets&.first&.order&.ticket_type&.name
    end
    column 'Invoice No.' do |r|
      r.tickets&.first&.order&.purchase_order&.invoice_no
    end
    column 'Status' do |r|
      r.tickets&.first&.order&.purchase_order&.status
    end
  end

  permit_params :first_name, :last_name, :email, :twitter, :size, :github

  form do |f|
    f.inputs 'Attendee' do
      f.input :first_name
      f.input :last_name
      f.input :email
      f.input :twitter
      f.input :cutting, as: :select, collection: ['Men size', 'Ladies size']
      f.input :size, as: :select, collection: ['XS', 'S', 'M', 'L', 'XL', 'XXL']
      f.input :github
    end
    f.actions
  end

  show do
    attributes_table do
      row :first_name
      row :last_name
      row :email
      row :cutting
      row :size
      row :twitter
      row :github
    end

    panel 'Events' do
      table_for attendee.tickets do
        column('Event') { |t| link_to t.order.ticket_type.event.name, admin_event_path(t.order.ticket_type.event) }
        column('Ticket') { |t| t.order.ticket_type.name }
        column('Order') { |t| t.order.purchase_order.invoice_no }
      end
    end
  end
end
