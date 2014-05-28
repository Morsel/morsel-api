class AddPlaces < ActiveRecord::Migration
  def change
    create_table :places do |t|
      t.string :name
      t.string :slug

      t.string :address
      t.string :city
      t.string :state
      t.string :postal_code
      t.string :country

      t.string :facebook_page_id
      t.string :twitter_username
      t.string :foursquare_venue_id

      t.json :foursquare_timeframes

      t.hstore :information, default: {}

      t.integer :creator_id

      t.timestamps
      t.datetime :deleted_at
    end

    add_index :places, [ :name, :foursquare_venue_id ]

    add_column :morsels, :place_id, :integer
    add_index :morsels, :place_id

    add_column :feed_items, :place_id, :integer
    add_index :feed_items, :place_id

    create_table :employments do |t|
      t.integer :place_id
      t.integer :user_id
      t.string :title
      t.datetime :deleted_at
    end

    add_index :employments, [ :place_id, :user_id ]
  end
end
