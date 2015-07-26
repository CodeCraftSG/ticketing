ActiveAdmin.register Attendee do
  menu priority: 6

  permit_params :first_name, :last_name, :email, :size, :twitter, :github
end
