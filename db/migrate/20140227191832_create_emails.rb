class CreateEmails < ActiveRecord::Migration
  def change
    create_table :emails do |t|
      t.string :class_name
      t.string :template_name
      t.string :from_email
      t.string :from_name

      t.boolean :stop_sending, default: false

      t.timestamps
    end
    add_index :emails, :class_name, unique: true
  end
end
