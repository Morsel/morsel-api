class FetchAndFollowSocialUidsWorker
  include Sidekiq::Worker
  sidekiq_options queue: :low

  # options:
  #   authentication_id: The `id` of the authentication
  def perform(options = nil)
    return if options.nil?
    authentication = Authentication.find(options['authentication_id'])

    if authentication.twitter?
      FollowTwitterFollowersWorker.perform_async({
        authentication_id: authentication.id
      })
      FollowTwitterFriendsWorker.perform_async({
        authentication_id: authentication.id
      })
    elsif authentication
      fetch_social_friend_uids_service = FetchSocialFriendUids.call(
        authentication: authentication
      )
      if fetch_social_friend_uids_service.valid? && fetch_social_friend_uids_service.response.count > 0
        follow_social_uids_service = FollowSocialUids.call(
          authentication: authentication,
          uids: (authentication.twitter? ? fetch_social_friend_uids_service.response.map(&:to_s) : fetch_social_friend_uids_service.response)
        )

        # Follow back
        if authentication.facebook?
          # Since Facebook has a two way relationship between connections, just follow back the same people
          follow_social_uids_service.response.each do |followed_user|
            Follow.create(followable_id: authentication.user_id, followable_type: 'User', follower_id: followed_user.id) if followed_user.auto_follow?
          end
        else
          fetch_social_follower_uids_service = FetchSocialFollowerUids.call(
            authentication: authentication
          )
          if fetch_social_follower_uids_service.valid? && fetch_social_follower_uids_service.response.count > 0
            ReverseFollowSocialUids.call(
              authentication: authentication,
              uids: (authentication.twitter? ? fetch_social_follower_uids_service.response.map(&:to_s) : fetch_social_follower_uids_service.response)
            )
          end
        end
      end
    end
  end
end
