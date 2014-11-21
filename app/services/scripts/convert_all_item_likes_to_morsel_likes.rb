module Scripts
  class ConvertAllItemLikesToMorselLikes
    include Service

    def call
      updated_count = 0
      destroyed_count = 0
      Like.includes(:likeable).where(likeable_type:'Item').find_each do |like|
        item = like.likeable
        morsel = item.morsel
        if like.liker.likes_morsel? morsel
          like.destroy!
          destroyed_count += 1
        else
          like.update!(likeable: morsel)
          updated_count += 1
        end
      end
      return updated_count, destroyed_count
    end
  end
end
