class SlimFollowedUserSerializer < SlimUserSerializer
  include FollowableSerializerAttributes

  attributes :following

  def following
    scope.present? && scope.following_user?(object)
  end
end
