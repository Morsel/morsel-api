class Subscription < ActiveRecord::Base
	belongs_to :morsel_keyword,:foreign_key => :keyword_id
	belongs_to :user
end
