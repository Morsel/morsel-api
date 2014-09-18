class FetchAndFollowSocialUidsWorker
  include Sidekiq::Worker
  sidekiq_options queue: :low

  # options:
  #   authentication_id: The `id` of the authentication
  def perform(options = nil)
    return if options.nil?

    authentication = Authentication.find(options['authentication_id'])
    if authentication
      fetch_social_friend_uids_service = FetchSocialFriendUids.call({
        authentication: authentication
      })
      if fetch_social_friend_uids_service.valid? && fetch_social_friend_uids_service.response.count > 0
        follow_social_uids_service = FollowSocialUids.call({
          authentication: authentication,
          uids: fetch_social_friend_uids_service.response
        })

        # Follow back
        if authentication.facebook?
          follow_social_uids_service.response.each do |followed_user|
            Follow.create(followable_id: authentication.user_id, followable_type: 'User', follower_id: followed_user.id) if followed_user.auto_follow?
          end
        end
      end
    end
  end
end
