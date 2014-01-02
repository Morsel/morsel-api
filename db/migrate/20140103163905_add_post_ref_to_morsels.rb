class AddPostRefToMorsels < ActiveRecord::Migration
  def change
    add_reference :morsels, :post, index: true
  end
end
