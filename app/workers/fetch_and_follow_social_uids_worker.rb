class FetchAndFollowSocialUidsWorker
  include Sidekiq::Worker
  sidekiq_options queue: :low

  # options:
  #   user_id: The `id` of the eventual follower
  #   provider: The social provider to fetch and follow Users from

  def perform(options = nil)
    return if options.nil?

    user = User.find(options['user_id'])

    authentications = user.authentications.where(provider: options['provider'])
    if authentications.count > 0
      authentication = authentications.first
      fetch_social_connection_uids_service = FetchSocialConnectionUids.call({
        authentication: authentication,
        user: user
      })
      if fetch_social_connection_uids_service.valid? && fetch_social_connection_uids_service.response.count > 0
        FollowSocialUids.call({
          authentication: authentication,
          uids: fetch_social_connection_uids_service.response,
          user: user
        })
      end
    end
  end
end
