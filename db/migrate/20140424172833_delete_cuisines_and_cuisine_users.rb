class DeleteCuisinesAndCuisineUsers < ActiveRecord::Migration
  def change
    drop_table :cuisines
    drop_table :cuisine_users
  end
end
