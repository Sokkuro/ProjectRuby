module Owner
  class RoomsController < ApplicationController
    before_action :authenticate_user!
    before_action :require_owner!
    before_action :set_room, only: %i[show edit update destroy]

    def index
      @rooms = current_user.rooms.order(:name)
    end

    def show
      @bookings = @room.bookings.includes(:user).order(:start_time)
    end

    def new
      @room = current_user.rooms.build
    end

    def create
      @room = current_user.rooms.build(room_params)
      if @room.save
        redirect_to owner_room_path(@room), notice: "Room created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @room.update(room_params)
        redirect_to owner_room_path(@room), notice: "Room updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @room.destroy
      redirect_to owner_rooms_path, notice: "Room removed."
    end

    private

    def require_owner!
      redirect_to root_path, alert: "Owners only." unless current_user&.owner?
    end

    def set_room
      @room = current_user.rooms.find(params[:id])
    end

    def room_params
      params.require(:room).permit(:name, :location, :price_per_hour, :is_active)
    end
  end
end
