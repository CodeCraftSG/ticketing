event = Event.where(name: "PHPConf.Asia 2019").first_or_create do |e|
  e.start_date = "2019-06-24"
  e.end_date = "2019-06-25"
  e.daily_start_time = "9:00am"
  e.daily_end_time = "5:00pm"
  e.description = "<b>The Pan-Asian PHP Conference!</b>\r\nInternational & Regional Speakers • 2 Days Conference • Single Track\r\n24 & 25 June 2019\r\nSingapore"
  e.contact_email = "orders@phpconf.asia"
  e.active = true
end

[
  {
    name: "Partners Pricing",
    description: "For community partners.",
    strikethrough_price: "350.0",
    price: "200.0",
    quota: 50,
    hidden: true,
    code: "phpsea2019",
    active: true,
    sale_starts_at: "2019-03-03 00:00:00",
    sale_ends_at: "2019-06-25 23:59:59",
    sequence: 0
  },
  {
    name: "Student",
    description: "For students in full-time education: Full access to both days of the conference. Lunch and tea breaks are provided. Please note that you will be asked to provide a copy of your student ID after payment.",
    strikethrough_price: nil,
    price: "45.0",
    quota: 0,
    hidden: false,
    code: "",
    active: true,
    sale_starts_at: "2019-03-03 00:00:00",
    sale_ends_at: "2019-06-25 23:59:59",
    sequence: 98
  },
  {
    name: "Early Bird",
    description: "Early birds get a good price: Full access to both days of the single conference. Lunch and tea breaks are provided. T-shirt and swag are included!",
    strikethrough_price: "350.0",
    price: "250.0",
    quota: 0,
    hidden: false,
    code: "",
    active: true,
    sale_starts_at: "2019-03-03 00:00:00",
    sale_ends_at: "2019-06-16 23:59:59",
    sequence: 2
  },
  {
    name: "Regular Ticket",
    description: "Full access to both days of the conference. Lunch and tea breaks are provided. T-shirt and swag are included!",
    strikethrough_price: nil,
    price: "350.0",
    quota: 0,
    hidden: false,
    code: "",
    active: true,
    sale_starts_at: "2019-03-03 00:00:00",
    sale_ends_at: "2019-06-25 23:59:59",
    sequence: 99
  }
].each do |ticket_type|
  event.ticket_types.where(name: ticket_type[:name]).first_or_create do |t|
    t.description = ticket_type[:description]
    t.strikethrough_price = ticket_type[:strikethrough_price]
    t.price = ticket_type[:price]
    t.quota = ticket_type[:quota]
    t.hidden = ticket_type[:hidden]
    t.code = ticket_type[:code]
    t.active = ticket_type[:active]
    t.sale_starts_at = ticket_type[:sale_starts_at]
    t.sale_ends_at = ticket_type[:sale_ends_at]
    t.sequence = ticket_type[:sequence]
  end
end
