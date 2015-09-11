ActiveAdmin.register Event do
  menu priority: 1

  permit_params :name, :start_date, :end_date, :daily_start_time, :daily_end_time, :description, :active,
    ticket_types_attributes: [:id, :sequence, :name,:description,:sale_starts_at,:sale_ends_at,:currency_unit,:price,
    :strikethrough_price,:quota,:entitlement, :restrict_quantity_per_order,:quantity_per_order,:hidden,:complimentary,:standalone,
    :needs_document,:code,:active,:_destroy]

  index do
    selectable_column
    column :name
    column :start_date
    column :end_date
    column 'Timing' do |event|
      "#{event.daily_start_time} - #{event.daily_end_time}"
    end
    column :active
    actions
  end

  filter :name
  filter :active
  filter :start_date
  filter :end_date

  controller do
    def new
      @event = Event.new
      @event.start_date = Date.today
      @event.end_date = Date.today
    end
  end

  form do |f|
    tabs do
      tab 'Event' do
        f.inputs 'Event' do
          f.input :name
          f.input :start_date, as: :datepicker
          f.input :end_date, as: :datepicker
          f.input :daily_start_time
          f.input :daily_end_time
          f.input :description
          f.input :active
        end
      end
      tab 'Ticket Types' do
        f.inputs do
          f.has_many :ticket_types, new_record: 'New Type', allow_destroy: true do |t|
            t.input :name
            t.input :description, input_html: {rows: 5}
            t.input :sale_starts_at
            t.input :sale_ends_at
            t.input :currency_unit
            t.input :price
            t.input :strikethrough_price, label: 'Strike Through Price'
            t.input :quota
            t.input :entitlement
            t.input :restrict_quantity_per_order
            t.input :quantity_per_order
            t.input :hidden
            t.input :complimentary
            t.input :standalone
            t.input :needs_document
            t.input :code
            t.input :active
          end
        end
      end
    end
    f.actions
  end

  member_action :attendance_list, method: :get do
    csv_data = CSV.generate(headers: true) do |csv|
      csv << %w(invoice date ticket first_name last_name email size)

      resource.purchase_orders.success.order('invoice_no ASC').each do |po|
        po.orders.each do |o|
          o.attendees.each do |a|
            csv << [po.invoice_no, po.created_at.strftime('%d-%b-%Y'), o.ticket_type.name, a.first_name, a.last_name, a.email, "#{a.cutting} #{a.size}"]
          end
        end
      end
    end
    send_data csv_data, filename: "event-#{resource.id}-attendees-#{Date.today}.csv"
  end

  sidebar 'Downloads', only: :show do
    div style: 'text-align: center' do
      button_to 'Download Attendees', attendance_list_admin_event_path(event), method: :get, form_html: {target:'_blank'}
    end
  end

  show do
    tabs do
      tab 'Event' do
        attributes_table do
          row :name
          row :start_date, label: 'From'
          row :end_date, label: 'To'
          row 'Timing' do |event|
            "#{event.daily_start_time} - #{event.daily_end_time}"
          end
          row 'Description' do |event| simple_format event.description end
          row 'Active' do |event| status_tag(event.active ? 'yes': 'no') end
          row 'Attendees' do |event| event.attendees.count end
          row 'Purchase Orders' do |event| event.purchase_orders.success.count end
          row 'Total Amount' do |event| number_to_currency(event.purchase_orders.success.reduce(0.0){ |sum,n| sum + n.total_amount.to_f }, unit: '$') end
        end
      end
      tab 'Attendees' do
        panel 'Ticket Holders' do
          paginated_collection(event.attendees.page(params[:page]), download_links: false) do
            table_for collection do
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
end
