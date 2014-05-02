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
      dummy_name = 'Facebook User'

      facebook_user = double('Hash')
      facebook_user.stub(:[]).with('id').and_return('12345_67890')
      facebook_user.stub(:[]).with('name').and_return(dummy_name)

      facebook_client = double('Koala::Facebook::API')

      Koala::Facebook::API.stub(:new).and_return(facebook_client)

      facebook_client.stub(:get_object).with('me').and_return('id' => '12345_67890')
      facebook_client.stub(:put_connections).and_return('id' => '12345_67890')
      facebook_client.stub(:put_picture).and_return('id' => '12345_67890')

      facebook_client
    end

    def stub_twitter_client
      twitter_client = double('Twitter::REST::Client')
      tweet = double('Twitter::Tweet')
      tweet.stub(:url).and_return('https://twitter.com/eatmorsel/status/12345')

      Twitter::Client.stub(:new).and_return(twitter_client)
      twitter_client.stub(:update_with_media).and_return(tweet)

      twitter_client
    end
  end
end
