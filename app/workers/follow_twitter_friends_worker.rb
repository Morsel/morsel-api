class FollowTwitterFriendsWorker
  include Sidekiq::Worker
  sidekiq_options queue: :low

  # options:
  #   authentication_id: The `id` of the authentication
  #   cursor
  def perform(options = nil)
    return if options.nil? || options['cursor'] == 0
    authentication = Authentication.find(options['authentication_id'])

    fetch_social_friend_uids_service = FetchSocialFriendUids.call(
      authentication: authentication,
      cursor: options['cursor']
    )

    if fetch_social_friend_uids_service.valid? && fetch_social_friend_uids_service.response.count > 0
      FollowSocialUids.call(
        authentication: authentication,
        uids: fetch_social_friend_uids_service.response.map(&:to_s)
      )

      next_cursor = fetch_social_friend_uids_service.response.attrs[:next_cursor]
      FollowTwitterFriendsWorker.delay_for(1.minute).perform_async(
        authentication_id: authentication.id,
        cursor: next_cursor
      ) if next_cursor > 0
    end
  end
end
