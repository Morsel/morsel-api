class RemoveColumnFromProfile < ActiveRecord::Migration
  def change
  	remove_column :profiles, :address
  end
end
