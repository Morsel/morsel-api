class AddCounterCaches < ActiveRecord::Migration
  def change
    add_counter_cache_column :items, :comments_count
    update_item_counter_caches

    add_counter_cache_column :keywords, :followers_count
    update_keyword_counter_caches

    add_counter_cache_column :morsels, :likes_count
    update_morsel_counter_caches

    add_counter_cache_column :places, :followers_count
    update_place_counter_caches

    add_counter_cache_column :users, :drafts_count
    add_counter_cache_column :users, :followed_users_count
    add_counter_cache_column :users, :followers_count
    update_user_counter_caches
  end

  private

  def add_counter_cache_column(table_name, column_name)
    add_column table_name, column_name, :integer, null: false, default: 0
  end

  def update_item_counter_caches
    Item.reset_column_information
    Item.find_each do |i|
      i.update comments_count: Comment.where(commentable_type:'Item', commentable_id:i.id).count
    end
  end

  def update_keyword_counter_caches
    Keyword.reset_column_information
    Keyword.find_each do |k|
      k.update followers_count: Follow.where(followable_id:k.id, followable_type:'Keyword').count
    end
  end

  def update_morsel_counter_caches
    Morsel.reset_column_information
    Morsel.find_each do |m|
      m.update likes_count: Like.where(likeable_type:'Morsel', likeable_id:m.id).count
    end
  end

  def update_place_counter_caches
    Place.reset_column_information
    Place.find_each do |p|
      p.update followers_count: Follow.where(followable_id:p.id, followable_type:'Place').count
    end
  end

  def update_user_counter_caches
    User.reset_column_information
    User.find_each do |u|
      u.update  drafts_count: Morsel.drafts.where(creator_id: u.id).count,
                followed_users_count: Follow.where(follower_id:u.id, followable_type:'User').count,
                followers_count: Follow.where(followable_id:u.id, followable_type:'User').count
    end
  end
end
