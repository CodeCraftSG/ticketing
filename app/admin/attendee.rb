ActiveAdmin.register Attendee do
  menu priority: 6

  config.batch_actions = false

  actions :all, except: [:destroy]

  filter :first_name
  filter :last_name
  filter :email
  filter :twitter
  filter :github

  index do
    column :first_name
    column :last_name
    column :email
    column :size
    column :twitter
    column :github
    actions
  end

  permit_params :first_name, :last_name, :email, :twitter, :size, :github

  form do |f|
    f.inputs 'Attendee' do
      f.input :first_name
      f.input :last_name
      f.input :email
      f.input :twitter
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
