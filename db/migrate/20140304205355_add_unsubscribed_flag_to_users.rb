class AddUnsubscribedFlagToUsers < ActiveRecord::Migration
  def change
    add_column :users, :unsubscribed, :boolean, default: false
  end
end
