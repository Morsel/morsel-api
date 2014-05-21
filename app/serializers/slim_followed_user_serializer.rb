class SlimFollowedUserSerializer < SlimUserSerializer
  attributes :following

  def following
    current_user.present? && current_user.following_user?(object)
  end
end

