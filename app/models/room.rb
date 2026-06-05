class Room < ApplicationRecord
  belongs_to :user
  has_many :bookings, dependent: :destroy

  validates :name, :location, presence: true
  validates :price_per_hour, numericality: { greater_than_or_equal_to: 0.01 }
  validates :user_id, presence: true

  def self.ransackable_attributes(auth_object = nil)
    %w[id name location price_per_hour user_id is_active created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[user bookings]
  end

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