class MorselKeyword < ActiveRecord::Base
	has_many :morsel_morsel_keywords
 	has_many :morsels, through: :morsel_morsel_keywords

 	has_one :user 

 	scope :subscribed_morsel_keywords, -> (user) { joins(:morsels).where(morsels:{id:user.subscribed_morsel_ids}).group('morsel_keywords.id') unless user.blank? }
end
