class AddUidAndNameIndexToAuthorizations < ActiveRecord::Migration
  def change
    add_index :authorizations, [:uid, :name]
  end
end
