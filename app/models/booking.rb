class Booking < ApplicationRecord
  STATUSES = %w[pending confirmed canceled].freeze

  belongs_to :room
  belongs_to :user

  validates :start_time, :end_time, presence: true
  validates :status, inclusion: { in: STATUSES }
  validates :total_price, numericality: { greater_than_or_equal_to: 0 }
  validate :end_after_start
  validate :no_overlapping_bookings

  before_validation :calculate_total_price, on: :create

  scope :overlapping, lambda { |start_time, end_time, room_id = nil|
    relation = where.not(status: "canceled")
                    .where("start_time < ? AND end_time > ?", end_time, start_time)
    relation = relation.where(room_id: room_id) if room_id.present?
    relation
  }

  def self.calculate_price(room, start_time, end_time)
    hours = (end_time - start_time) / 3600.0
    (room.price_per_hour * hours).round(2)
  end

  def self.total_price(room, start_time, end_time)
    calculate_price(room, start_time, end_time)
  end

  def duration_hours
    (end_time - start_time) / 3600.0
  end

  private

  def end_after_start
    return if start_time.blank? || end_time.blank?

    errors.add(:end_time, "must be after start time") if end_time <= start_time
  end

  def no_overlapping_bookings
    return if start_time.blank? || end_time.blank? || room_id.blank?
    return if status == "canceled"

    overlap = Booking.overlapping(start_time, end_time, room_id)
    overlap = overlap.where.not(id: id) if persisted?

    errors.add(:base, "Time slot overlaps with an existing booking") if overlap.exists?
  end

  def calculate_total_price
    return unless room && start_time && end_time

    self.total_price = self.class.calculate_price(room, start_time, end_time)
  end
end
