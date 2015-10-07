class CreateAssociationRequests < ActiveRecord::Migration
  def change
    create_table :association_requests do |t|

      t.integer  :host_id,   :null => false
      t.integer  :associated_user_id,    :null => false
      t.boolean  :approved,	  :default => false

      t.timestamps
    end
  end
end
