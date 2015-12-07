class UseridToAssociateMorsel < ActiveRecord::Migration
  def change
    add_column :associated_morsels, :user_id, :integer
  end
end
