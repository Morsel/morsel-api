class AddHiddenToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :hidden, :boolean, default: false
    Activity.update_all hidden: false
  end
end
