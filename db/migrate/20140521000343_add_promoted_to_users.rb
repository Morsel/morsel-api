class AddPromotedToUsers < ActiveRecord::Migration
  def change
    add_column :users, :promoted, :boolean, default: false
    add_index(:users, [ :promoted, :first_name, :last_name ])
  end
end
