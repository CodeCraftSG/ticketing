class Order < ActiveRecord::Base
  belongs_to :ticket_type
end
