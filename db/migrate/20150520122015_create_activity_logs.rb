class CreateActivityLogs < ActiveRecord::Migration
  def change
    create_table :activity_logs do |t|
      
      t.string :ip_address
      t.string :host_site
      t.string :share_by
      t.string :activity
      t.integer :activity_id
      t.string  :activity_type
      t.integer :user_id
      t.timestamps
    end
    add_index :activity_logs, :activity_id
  end
end
