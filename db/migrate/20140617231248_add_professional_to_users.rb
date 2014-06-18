class AddProfessionalToUsers < ActiveRecord::Migration
  def up
    add_column :users, :professional, :boolean, default: false
    User.where(industry: 'chef').update_all professional: true
  end

  def down
    remove_column :users, :professional
  end
end
