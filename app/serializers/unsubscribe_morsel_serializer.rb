class UnsubscribeMorselSerializer < ActiveModel::Serializer
  attributes :id,
             :name,
             :first_morsel,
             :creator_info
 # has_many :morsels, serializer: SlimMorselSerializer

  def first_morsel
    if object.morsels.present?
      morsel = object.morsels.published.order(published_at: :desc).first
      SlimMorselSerializer.new(morsel).attributes
    end
  end

  def creator_info
    if object.morsels.present?
      user_id = object.morsels.published.order(published_at: :desc).first.creator_id
      user = User.find(user_id)
      SlimUserSerializer.new(user).attributes
    end
  end

end
