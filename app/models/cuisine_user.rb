class CuisineUser < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :cuisine
  belongs_to :user
end
