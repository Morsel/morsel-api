class AddUserIdToSubscriber < ActiveRecord::Migration
  def change
    add_column :subscribers, :user_id, :integer
    add_index :subscribers, :user_id
  end
end
