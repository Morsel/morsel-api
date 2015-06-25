class MorselKeyword < ActiveRecord::Base
	has_many :morsel_morsel_keywords
 	has_many :morsels, through: :morsel_morsel_keywords
end
