ActiveAdmin.register TicketType do
  menu priority: 2

  permit_params :event_id, :sequence, :name, :description, :strikethrough_price, :price, :quota, :hidden, :code, :active, :sale_starts_at, :sale_ends_at, :complimentary, :standalone, :needs_document, :currency_unit

  config.sort_order = 'sequence_asc'

  index do
    selectable_column
    column :event
    column :sequence
    column :name
    column 'Price' do |e|
      str = []
      str << number_to_currency(e.price, unit: e.currency_unit)
      str << "<strike>#{number_to_currency(e.strikethrough_price, unit: e.currency_unit)}</strike>".html_safe if e.strikethrough_price.present?

      str.join('<br/>').html_safe
    end
    column('Quota') do |e|
      "#{e.attendees.count}/#{e.quota}"
    end
    column :hidden
    column :complimentary
    column :standalone
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
  filter :complimentary
  filter :standalone
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
      f.input :currency_unit
      f.input :price
      f.input :strikethrough_price, label: 'Strike Through Price'
      f.input :quota
      f.input :hidden
      f.input :complimentary
      f.input :standalone
      f.input :needs_document
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
      row('Price'){ |t| number_to_currency(t.price, unit: t.currency_unit) }
      row 'Strike Through Price' do |t|
        "<strike>#{number_to_currency(t.strikethrough_price, unit: t.currency_unit)}</strike>".html_safe
      end if ticket_type.strikethrough_price
      row('Quota') do |t|
        "#{t.attendees.count}/#{t.quota}"
      end
      row('Hidden'){ |t| status_tag(t.hidden? ? 'yes' : 'no') }
      row('Complimentary'){ |t| status_tag(t.complimentary? ? 'yes' : 'no') }
      row('Standalone'){ |t| status_tag(t.standalone? ? 'yes' : 'no') }
      row('Needs Document?'){ |t| status_tag(t.needs_document? ? 'yes' : 'no') }
      row :code if ticket_type.code.present?
      row('Active'){ |t| status_tag(t.active ? 'yes' : 'no') }
    end
  end
end
