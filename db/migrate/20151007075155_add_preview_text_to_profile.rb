class AddPreviewTextToProfile < ActiveRecord::Migration
  def change
  	add_column :profiles, :preview_text, :text
  end
end
