class AddUserRefToMorsels < ActiveRecord::Migration
  def change
    add_reference :morsels, :user, index: true
  end
end
