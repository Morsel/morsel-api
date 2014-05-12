module Requests
  module ServiceStubs
    def stub_bitly_client
      bitly_client = double('Bitly::V3::Client')
      Bitly.stub(:client).and_return(bitly_client)

      bitly_url = double('Bitly::Url')
      bitly_url.stub(:short_url).and_return('http://mrsl.co/test')
      bitly_client.stub(:shorten).and_return(bitly_url)

      bitly_client
    end

    def stub_facebook_client
      facebook_user = double('Hash')
      facebook_user.stub(:[]).with('id').and_return('facebook_user_id')
      facebook_user.stub(:[]).with('name').and_return('facebook_user_name')
      facebook_user.stub(:[]).with('link').and_return('facebook_user_link')

      facebook_client = double('Koala::Facebook::API')

      Koala::Facebook::API.stub(:new).and_return(facebook_client)

      facebook_client.stub(:get_object).with('me').and_return('id' => 'facebook_user_id')
      facebook_client.stub(:put_connections).and_return('id' => 'facebook_user_id')
      facebook_client.stub(:put_picture).and_return('id' => 'facebook_user_id')

      facebook_client
    end

    def stub_facebook_oauth(short_lived_token)
      facebook_oauth = double('Koala::Facebook::OAuth')
      Koala::Facebook::OAuth.stub(:new).and_return(facebook_oauth)

      facebook_oauth.stub(:exchange_access_token).with(short_lived_token).and_return('new_access_token')
    end

    def stub_twitter_client
      twitter_client = double('Twitter::REST::Client')
      tweet = double('Twitter::Tweet')
      tweet.stub(:url).and_return('https://twitter.com/eatmorsel/status/12345')

      Twitter::Client.stub(:new).and_return(twitter_client)
      twitter_client.stub(:update_with_media).and_return(tweet)

      twitter_user = double('Twitter::User')
      twitter_client.stub(:current_user).and_return(twitter_user)
      twitter_user.stub(:id).and_return('twitter_user_id')
      twitter_user.stub(:screen_name).and_return('eatmorsel')
      twitter_user.stub(:url).and_return("https://twitter.com/eatmorsel")

      twitter_client
    end
  end
end
