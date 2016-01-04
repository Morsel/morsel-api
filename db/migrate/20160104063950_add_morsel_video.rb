class AddMorselVideo < ActiveRecord::Migration
  def change
    add_column :morsels, :morsel_video, :text
    add_column :morsels, :video_text, :text
  end
end


