class DeleteMorselidSubscription < ActiveRecord::Migration
  def change
  	remove_column :subscriptions, :morsel_id
  end
end
