class FetchAndFollowSocialUidsWorker
  include Sidekiq::Worker
  sidekiq_options queue: :low

  # options:
  #   authentication_id: The `id` of the authentication
  def perform(options = nil)
    return if options.nil?

    authentication = Authentication.find(options['authentication_id'])
    if authentication
      fetch_social_connection_uids_service = FetchSocialConnectionUids.call({
        authentication: authentication
      })
      if fetch_social_connection_uids_service.valid? && fetch_social_connection_uids_service.response.count > 0
        FollowSocialUids.call({
          authentication: authentication,
          uids: fetch_social_connection_uids_service.response
        })
      end
    end
  end
end
