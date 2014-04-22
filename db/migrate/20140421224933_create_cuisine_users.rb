class CreateCuisineUsers < ActiveRecord::Migration
  def change
    create_table :cuisine_users, id: false do |t|
      t.integer :cuisine_id
      t.integer :user_id
      t.datetime :deleted_at
    end

    add_index :cuisine_users, :cuisine_id
    add_index :cuisine_users, :user_id
  end
end
