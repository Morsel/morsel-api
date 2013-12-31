ActiveAdmin.register User do

  index do
    selectable_column
    column :id
    column :email
    column 'Full Name' do |user|
      "#{user.first_name} #{user.last_name}"
    end
    column :admin
    column :last_sign_in_at
    column :created_at
    default_actions
  end

end
