ActiveAdmin.register Booking do
  permit_params :room_id, :user_id, :start_time, :end_time, :total_price, :status

  index do
    selectable_column
    id_column
    column :room
    column :user
    column :start_time
    column :end_time
    column :total_price
    column :status
    actions
  end

  filter :status, as: :select, collection: Booking::STATUSES
  filter :room
  filter :user

  form do |f|
    f.inputs do
      f.input :room
      f.input :user
      f.input :start_time, as: :datetime_select
      f.input :end_time, as: :datetime_select
      f.input :total_price
      f.input :status, as: :select, collection: Booking::STATUSES
    end
    f.actions
  end

  member_action :confirm, method: :put do
    resource.update!(status: "confirmed")
    redirect_to resource_path, notice: "Booking confirmed."
  end

  member_action :cancel, method: :put do
    resource.update!(status: "canceled")
    redirect_to resource_path, notice: "Booking canceled."
  end

  action_item :confirm, only: :show, if: proc { resource.status == "pending" } do
    link_to "Confirm", confirm_admin_booking_path(resource), data: { turbo_method: :put }
  end

  action_item :cancel, only: :show, if: proc { resource.status != "canceled" } do
    link_to "Cancel", cancel_admin_booking_path(resource), data: { turbo_method: :put }
  end
end