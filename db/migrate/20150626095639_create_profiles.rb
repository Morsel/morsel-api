class CreateProfiles < ActiveRecord::Migration
  def change
    create_table :profiles do |t|
      t.string :host_url
      t.string :host_logo
      t.string :address
      t.references :user

      t.timestamps
    end
  end
end
