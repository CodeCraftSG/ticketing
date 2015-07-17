ActiveAdmin.register Event do
  menu priority: 1

  permit_params :name, :start_date, :end_date, :daily_start_time, :daily_end_time, :description, :active

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
    f.inputs 'Event' do
      f.input :name
      f.input :start_date, as: :datepicker
      f.input :end_date, as: :datepicker
      f.input :daily_start_time
      f.input :daily_end_time
      f.input :description
      f.input :active
    end
    f.actions
  end

  show do
    attributes_table do
      row :name
      row :start_date, label: 'From'
      row :end_date, label: 'To'
      row 'Timing' do |event|
        "#{event.daily_start_time} - #{event.daily_end_time}"
      end
      row :description
      row 'Active' do |event| status_tag(event.active ? 'yes': 'no') end
    end
  end
end
