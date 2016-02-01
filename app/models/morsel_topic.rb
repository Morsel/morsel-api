class MorselTopic < ActiveRecord::Base
  has_many :morsel_morsel_topics, dependent: :destroy
  has_many :morsels, through: :morsel_morsel_topics
  has_one :user

  scope :subscribed_morsel_topics, -> (user) { joins(:morsels).where(morsels:{id:user.subscribed_morsel_ids}).group('morsel_topics.id') unless user.blank? }

end
