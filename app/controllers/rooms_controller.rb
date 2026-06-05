class RoomsController < ApplicationController
  def index
    @rooms = Room.active.includes(:user).order(:name)
  end

  def show
    @room = Room.active.find(params[:id])
    @occupied_slots = @room.bookings.where.not(status: "canceled").order(:start_time)
  end
end
