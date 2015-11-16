class MorselTopic < ActiveRecord::Base
  has_many :morsel_morsel_topics, dependent: :destroy
  has_many :morsels, through: :morsel_morsel_topics
  has_one :user

end
