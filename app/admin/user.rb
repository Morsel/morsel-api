ActiveAdmin.register User do
  config.clear_action_items!
  config.filters = false

  index do
    selectable_column
    column :id
    column :photo do |user|
      image_tag(user.photo.url(:_40x40)) if user.photo
    end
    column :email
    column :username
    column :full_name
    column :title
    column :industry
    column :admin
    column :active
    column :last_sign_in_at
    column :created_at
    default_actions
  end
end
