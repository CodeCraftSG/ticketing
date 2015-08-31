ActiveAdmin.register TicketType do
  menu priority: 2

  permit_params :event_id, :sequence, :name, :description, :strikethrough_price, :price, :quota, :hidden, :code, :active, :sale_starts_at, :sale_ends_at, :complimentary, :standalone, :needs_document, :currency_unit, :entitlement

  config.sort_order = 'sequence_asc'

  index do
    selectable_column
    column :event
    column :sequence
    column :name
    column 'Sale Period' do |t|
      date_range(t.sale_starts_at, t.sale_ends_at)
    end
    column 'Price' do |e|
      str = []
      str << number_to_currency(e.price, unit: e.currency_unit)
      str << "<strike>#{number_to_currency(e.strikethrough_price, unit: e.currency_unit)}</strike>".html_safe if e.strikethrough_price.present?

      str.join('<br/>').html_safe
    end
    column('Stats') do |e|
      display = []
      display << "Entitlement: #{e.entitlement}"
      display << "Orders: #{e.orders.select{|o| o.purchase_order.status == 'success' }.count}"
      display << "Qty: #{e.orders.select{|o| o.purchase_order.status == 'success' }.reduce(0) do |sum,order| sum + order.quantity end}"
      display << "Sold: #{e.orders.select{|o| o.purchase_order.status == 'success' }.reduce(0) do |sum,order| sum + (e.entitlement * order.quantity) end}"
      display << "Quota: #{e.quota}"
      display << "Attendees: #{e.attendees.count}"
      display.join('<br/>').html_safe
    end
    column :hidden
    column :standalone
    column :code
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
      f.input :entitlement
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
    tabs do
      tab 'Ticket Type' do
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
          row :entitlement
          row('Hidden'){ |t| status_tag(t.hidden? ? 'yes' : 'no') }
          row('Complimentary'){ |t| status_tag(t.complimentary? ? 'yes' : 'no') }
          row('Standalone'){ |t| status_tag(t.standalone? ? 'yes' : 'no') }
          row('Needs Document?'){ |t| status_tag(t.needs_document? ? 'yes' : 'no') }
          row :code if ticket_type.code.present?
          row('Active'){ |t| status_tag(t.active ? 'yes' : 'no') }
        end
      end
      tab 'Attendees' do
        panel 'Ticket Holders' do
          table_for ticket_type.attendees do |attendee|
            column('First name') { |t| t.first_name }
            column('Last name') { |t| t.last_name }
            column('Email') { |t| t.email }
            column('Size') { |t| "#{t.cutting} #{t.size}" }
            column('Twitter') { |t| t.twitter }
            column('Github') { |t| t.github }
          end
        end
      end
    end
  end
end
