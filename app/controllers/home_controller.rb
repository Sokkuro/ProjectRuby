class HomeController < ApplicationController
  def index
    @recent_rooms = Room.active.order(created_at: :desc).limit(3)
  end
end
