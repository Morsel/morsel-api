ActiveAdmin.register User do
  actions :index, :show
  filter :email
  filter :username
  filter :first_name
  filter :last_name
  filter :active

  config.clear_action_items!

  index do
    selectable_column
    column :id
    column :photo do |user|
      image_tag(user.photo.url(:_40x40)) if user.photo
    end
    column :email
    column :username
    column :full_name
    column :industry
    column :admin
    column :active
    column :current_sign_in_at
    column :created_at
    actions
  end
end
