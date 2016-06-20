event = Event.create(
  name: "PHPConf.Asia 2016",
  start_date: "2016-08-22",
  end_date: "2016-08-25",
  daily_start_time: "9:00am",
  daily_end_time: "5:00pm",
  description: "<b>The Pan-Asian PHP Conference!</b>\r\nInternational & Regional Speakers • Tutorial + 2 Days Conference • Single Track\r\n22 to 24 August 2016\r\nSingapore",
  active: true
)

TicketType.destroy_all
TicketType.create!([
  {event_id: 1, name: "Partners Pricing", description: "For community partners.", strikethrough_price: nil, price: "195.0", quota: 50, hidden: true, code: "phpsea2016", active: true, sale_starts_at: "2016-06-21 00:00:00", sale_ends_at: "2016-07-01 00:00:00", sequence: 0},
  {event_id: 1, name: "Student (Early Bird)", description: "For students in full-time education: Full access to both days of the conference. Lunch and tea breaks are provided. Please note that you will be asked to provide a copy of your student ID after payment.", strikethrough_price: nil, price: "90.0", quota: 0, hidden: false, code: "", active: true, sale_starts_at: "2016-07-18 00:00:00", sale_ends_at: "2016-08-15 23:59:59", sequence: 97},
  {event_id: 1, name: "Student", description: "For students in full-time education: Full access to both days of the conference. Lunch and tea breaks are provided. Please note that you will be asked to provide a copy of your student ID after payment.", strikethrough_price: nil, price: "120.0", quota: 0, hidden: false, code: "", active: true, sale_starts_at: "2016-08-16 00:00:00", sale_ends_at: "2016-08-23 00:00:00", sequence: 98},
  {event_id: 1, name: "Super Early Bird", description: "Sign up early for the best price: Full access to both days of the conference. Lunch and tea breaks are provided. T-shirt and swag are included!", strikethrough_price: nil, price: "250.0", quota: 0, hidden: false, code: "", active: true, sale_starts_at: "2016-07-28 00:00:00", sale_ends_at: "2016-08-04 23:59:59", sequence: 1},
  {event_id: 1, name: "Early Bird", description: "Early birds get a good price: Full access to both days of the single conference. Lunch and tea breaks are provided. T-shirt and swag are included!", strikethrough_price: nil, price: "295.0", quota: 0, hidden: false, code: "", active: true, sale_starts_at: "2016-08-05 00:00:00", sale_ends_at: "2016-08-31 23:59:59", sequence: 2},
  {event_id: 1, name: "Regular Ticket", description: "Full access to both days of the conference. Lunch and tea breaks are provided. T-shirt and swag are included!", strikethrough_price: nil, price: "350.0", quota: 0, hidden: false, code: "", active: true, sale_starts_at: "2016-08-01 00:00:00", sale_ends_at: "2016-08-23 00:00:00", sequence: 99}
])
