class AddActiveUserToProfile < ActiveRecord::Migration
  def change
  	add_column :profiles, :is_active, :boolean,:default => false
  end
end
