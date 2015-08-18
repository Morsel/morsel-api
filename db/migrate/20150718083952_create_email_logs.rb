class CreateEmailLogs < ActiveRecord::Migration
  def change
    create_table :email_logs do |t|
  	  t.references  :morsel, index: true
      t.references  :user, index: true
      t.timestamps
    end
  end
end
