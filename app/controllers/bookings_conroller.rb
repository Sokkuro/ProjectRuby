class BookingsController < ApplicationController
  before_action :authenticate_user!

  def new
    @room = Room.active.find(params[:room_id])
    @booking = Booking.new(room: @room)
  end

  def create
    @room = Room.active.find(booking_params[:room_id])
    @booking = current_user.bookings.build(booking_params)
    @booking.room = @room
    @booking.status = "confirmed"

    if @booking.save
      redirect_to my_bookings_path, notice: "Бронь создана. Демо-оплата прошла успешно!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def booking_params
    params.require(:booking).permit(:room_id, :start_time, :end_time)
  end
end
