class AddNonceToMorsels < ActiveRecord::Migration
  def change
    add_column :morsels, :nonce, :string
  end
end
