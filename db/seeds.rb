puts "Seeding database..."

admin = User.find_or_create_by!(email: "admin@example.com") do |u|
  u.password = "password"
  u.password_confirmation = "password"
  u.role = "admin"
end

owner1 = User.find_or_create_by!(email: "owner1@example.com") do |u|
  u.password = "password"
  u.password_confirmation = "password"
  u.role = "owner"
end

owner2 = User.find_or_create_by!(email: "owner2@example.com") do |u|
  u.password = "password"
  u.password_confirmation = "password"
  u.role = "owner"
end

client = User.find_or_create_by!(email: "client@example.com") do |u|
  u.password = "password"
  u.password_confirmation = "password"
  u.role = "client"
end

room1 = Room.find_or_create_by!(name: "Open Space A", user: owner1) do |r|
  r.location = "Moscow, Tverskaya 1"
  r.price_per_hour = 500
  r.is_active = true
end

room2 = Room.find_or_create_by!(name: "Meeting Room B", user: owner1) do |r|
  r.location = "Moscow, Tverskaya 1"
  r.price_per_hour = 1200
  r.is_active = true
end

room3 = Room.find_or_create_by!(name: "Private Office C", user: owner2) do |r|
  r.location = "Saint Petersburg, Nevsky 10"
  r.price_per_hour = 800
  r.is_active = true
end

base_time = Time.zone.parse("2026-06-10 09:00")

bookings_data = [
  { room: room1, user: client, start_time: base_time, end_time: base_time + 2.hours, status: "confirmed" },
  { room: room1, user: client, start_time: base_time + 4.hours, end_time: base_time + 5.hours, status: "pending" },
  { room: room2, user: client, start_time: base_time + 1.day, end_time: base_time + 1.day + 3.hours, status: "confirmed" },
  { room: room3, user: admin, start_time: base_time + 2.days, end_time: base_time + 2.days + 1.hour, status: "canceled" },
  { room: room3, user: client, start_time: base_time + 3.days, end_time: base_time + 3.days + 2.hours, status: "pending" }
]

bookings_data.each do |attrs|
  booking = Booking.find_or_initialize_by(
    room: attrs[:room],
    user: attrs[:user],
    start_time: attrs[:start_time],
    end_time: attrs[:end_time]
  )
  booking.status = attrs[:status]
  booking.total_price = Booking.calculate_price(attrs[:room], attrs[:start_time], attrs[:end_time])
  booking.save!
end

puts "Done! Admin: admin@example.com / password"
