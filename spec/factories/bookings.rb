FactoryBot.define do
  factory :booking do
    association :room
    association :user
    start_time { 1.day.from_now.change(hour: 10) }
    end_time { 1.day.from_now.change(hour: 12) }
    status { "pending" }
    total_price { 0 }

    after(:build) do |booking|
      booking.total_price = Booking.calculate_price(
        booking.room,
        booking.start_time,
        booking.end_time
      )
    end
  end
end
