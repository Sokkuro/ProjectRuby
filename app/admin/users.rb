ActiveAdmin.register User do
  permit_params :email, :role, :password, :password_confirmation

  index do
    selectable_column
    id_column
    column :email
    column :role
    column :provider
    column :created_at
    actions
  end

  filter :email
  filter :role, as: :select, collection: User::ROLES

  form do |f|
    f.inputs do
      f.input :email
      f.input :role, as: :select, collection: User::ROLES
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end

  show do
    attributes_table do
      row :id
      row :email
      row :role
      row :provider
      row :uid
      row :created_at
      row :updated_at
    end
  end
end