class AddColumnCreatorIdToSubscriptions < ActiveRecord::Migration
  def change
  	 add_column :subscriptions, :creator_id, :integer
  	 add_column :subscriptions, :keyword_id, :integer
  end
end
