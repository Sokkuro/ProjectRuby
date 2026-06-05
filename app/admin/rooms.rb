ActiveAdmin.register Room do
  permit_params :name, :location, :price_per_hour, :user_id, :is_active

  index do
    selectable_column
    id_column
    column :name
    column :location
    column :price_per_hour
    column :user
    column :is_active
    actions
  end

  filter :name
  filter :location
  filter :is_active
  filter :user, as: :select, collection: -> { User.where(role: "owner").pluck(:email, :id) }

  form do |f|
    f.inputs do
      f.input :name
      f.input :location
      f.input :price_per_hour
      f.input :user, as: :select, collection: User.where(role: %w[owner admin])
      f.input :is_active
    end
    f.actions
  end
end