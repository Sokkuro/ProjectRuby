class Room < ApplicationRecord
  belongs_to :user
  has_many :bookings, dependent: :destroy

  validates :name, :location, presence: true
  validates :price_per_hour, numericality: { greater_than: 0 }
  validates :user_id, presence: true

  scope :active, -> { where(is_active: true) }

  scope :available_at, lambda { |time_range_start, time_range_end|
    active.where.not(
      id: Booking.overlapping(time_range_start, time_range_end).select(:room_id)
    )
  }

  def occupied_slots
    bookings.where.not(status: "canceled").pluck(:start_time, :end_time)
  end
end
