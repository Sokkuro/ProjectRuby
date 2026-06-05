class MyBookingsController < ApplicationController
  before_action :authenticate_user!

  def index
    @bookings = current_user.bookings.includes(:room).order(start_time: :desc)
  end
end
