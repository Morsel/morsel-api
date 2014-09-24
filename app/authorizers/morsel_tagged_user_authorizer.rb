class MorselTaggedUserAuthorizer < ApplicationAuthorizer
  def creatable_by?(user)
    # current_user is the tagged morsel creator
    return false unless resource.morsel.creator_id == user.id

    # you can only morsel tag users who follow you
    resource.user.following_user? user
  end
end
