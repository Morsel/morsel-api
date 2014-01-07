class CreateMorselsPosts < ActiveRecord::Migration
  def change
    create_table :morsels_posts, id: false do |t|
      t.references :morsel
      t.references :post
    end

    add_index(:morsels_posts, [ :morsel_id, :post_id ])
  end
end
