class AddActiveFlagVerifiedAtAndTypeToUser < ActiveRecord::Migration
  def change
    add_column :users, :active, :boolean, default: true
    add_column :users, :verified_at, :datetime
    add_column :users, :type, :string, default: 'User'
  end
end
