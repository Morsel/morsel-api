class AddTimestampsToEmployments < ActiveRecord::Migration
  def change
    change_table :employments do |t|
      t.timestamps
    end
  end
end
