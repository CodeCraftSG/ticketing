ActiveAdmin.register TicketType do
  menu priority: 2

  permit_params :event_id, :sequence, :name, :description, :strikethrough_price, :price, :quota, :hidden, :code, :active, :sale_starts_at, :sale_ends_at

  config.sort_order = 'sequence_asc'

  index do
    selectable_column
    column :event
    column :sequence
    column :name
    column 'Price' do |e|
      str = []
      str << number_to_currency(e.price)
      str << "<strike>#{number_to_currency(e.strikethrough_price)}</strike>".html_safe if e.strikethrough_price.present?

      str.join('<br/>').html_safe
    end
    column :quota
    column :hidden
    column :code
    column :sale_starts_at
    column :sale_ends_at
    column :active
    actions
  end

  filter :event
  filter :name
  filter :code
  filter :sale_starts_at
  filter :sale_ends_at
  filter :hidden
  filter :active

  controller do
    def new
      @ticket_type = TicketType.new(active: true, quota: 0, hidden: false, sale_starts_at: Date.today, sale_ends_at: Date.today)
    end
  end

  form do |f|
    f.inputs 'Ticket Type' do
      f.input :event
      f.input :sequence
      f.input :name
      f.input :description
      f.input :sale_starts_at
      f.input :sale_ends_at
      f.input :price
      f.input :strikethrough_price, label: 'Strike Through Price'
      f.input :quota
      f.input :hidden
      f.input :code
      f.input :active
    end
    f.actions
  end

  show do
    attributes_table do
      row :event
      row :sequence
      row :name
      row :description
      row :sale_starts_at
      row :sale_ends_at
      row('Price'){ |t| number_to_currency(t.price) }
      row 'Strike Through Price' do |t|
        "<strike>#{number_to_currency(t.strikethrough_price)}</strike>".html_safe
      end if ticket_type.strikethrough_price
      row :quota
      row('Hidden'){ |t| status_tag(t.hidden ? 'yes' : 'no') }
      row :code if ticket_type.code.present?
      row('Active'){ |t| status_tag(t.active ? 'yes' : 'no') }
    end
  end
end
