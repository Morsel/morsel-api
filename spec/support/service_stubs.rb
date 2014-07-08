module ServiceStubs
  def stub_aws_s3_client
    aws_s3_client = double('AWS::S3')
    AWS::S3.stub(:new).and_return(aws_s3_client)

    presigned_post = double('AWS::S3::PresignedPost')

    presigned_post.stub(:fields).and_return({
      "AWSAccessKeyId"=>"AWS_ACCESS_KEY_ID",
      "key"=> "KEY-${filename}",
      "policy"=> "POLICY",
      "signature"=>"SIGNATURE",
      "acl"=>"ACL"
    })
    presigned_post.stub(:url).and_return(URI.parse('http://www.eatmorsel.com'))

    bucket = double('AWS::S3::Bucket')
    bucket.stub(:presigned_post).and_return(presigned_post)

    aws_s3_client.stub(:buckets).and_return({ Settings.aws.buckets.default => bucket })

    aws_s3_client
  end

  def stub_bitly_client
    bitly_client = double('Bitly::V3::Client')
    Bitly.stub(:client).and_return(bitly_client)

    bitly_url = double('Bitly::Url')
    bitly_url.stub(:short_url).and_return('http://mrsl.co/test')
    bitly_client.stub(:shorten).and_return(bitly_url)

    bitly_client
  end

  def stub_facebook_client(options = {})
    options[:id] ||= 'facebook_user_id'

    facebook_user = double('Hash')
    facebook_user.stub(:[]).with('id').and_return(options[:id])
    facebook_user.stub(:[]).with('name').and_return('facebook_user_name')
    facebook_user.stub(:[]).with('link').and_return('facebook_user_link')

    facebook_client = double('Koala::Facebook::API')

    Koala::Facebook::API.stub(:new).and_return(facebook_client)

    facebook_client.stub(:get_object).with('me').and_return('id' => options[:id])
    facebook_client.stub(:put_connections).and_return('id' => options[:id])
    facebook_client.stub(:put_picture).and_return('id' => options[:id])

    facebook_client
  end

  def stub_facebook_oauth(short_lived_token)
    facebook_oauth = double('Koala::Facebook::OAuth')
    Koala::Facebook::OAuth.stub(:new).and_return(facebook_oauth)

    facebook_oauth.stub(:exchange_access_token).with(short_lived_token).and_return('new_access_token')
  end

  def stub_twitter_client(options = {})
    options[:id] ||= 'twitter_user_id'

    twitter_client = double('Twitter::REST::Client')
    tweet = double('Twitter::Tweet')
    tweet.stub(:url).and_return('https://twitter.com/eatmorsel/status/12345')

    Twitter::Client.stub(:new).and_return(twitter_client)
    twitter_client.stub(:update_with_media).and_return(tweet)

    twitter_user = double('Twitter::User')
    twitter_client.stub(:current_user).and_return(twitter_user)
    twitter_user.stub(:id).and_return(options[:id])
    twitter_user.stub(:screen_name).and_return('eatmorsel')
    twitter_user.stub(:url).and_return("https://twitter.com/eatmorsel")

    twitter_client
  end

  def stub_foursquare_suggest(options = {})
    options[:count] ||= 1

    foursquare_client = double('Foursquare2::Client')
    Foursquare2::Client.stub(:new).and_return(foursquare_client)

    foursquare_minivenues = []
    options[:count].times do
      foursquare_minivenues << FactoryGirl.build(:foursquare_venue)
    end

    foursquare_client.stub(:suggest_completion_venues).and_return(foursquare_minivenues)
  end

  def stub_foursquare_venue(options = {})
    options[:foursquare_venue_id] ||= 'foursquare_venue_id'
    options[:name] ||= Faker::Company.name
    options[:location] ||= {}
    options[:location][:address] ||= Faker::Address.street_address
    options[:url] ||= Faker::Internet.url

    foursquare_client = double('Foursquare2::Client')
    Foursquare2::Client.stub(:new).and_return(foursquare_client)

    foursquare_venue = double('Hash')
    foursquare_venue.stub(:[]).with('name').and_return(options[:name])
    foursquare_venue.stub(:[]).with('url').and_return(options[:website_url])
    foursquare_venue.stub(:[]).with('location').and_return('address' => options[:location][:address])
    foursquare_venue.stub(:[]).with('attributes').and_return(nil)
    foursquare_venue.stub(:[]).with('contact').and_return(nil)
    foursquare_venue.stub(:[]).with('hours').and_return(nil)
    foursquare_venue.stub(:[]).with('menu').and_return(nil)
    foursquare_venue.stub(:[]).with('price').and_return(nil)
    foursquare_venue.stub(:[]).with('reservations').and_return(nil)

    foursquare_client.stub(:venue).with(options[:foursquare_venue_id]).and_return(foursquare_venue)

    foursquare_client
  end

  def stub_foursquare_venue_not_found(options = {})
    foursquare_client = double('Foursquare2::Client')
    Foursquare2::Client.stub(:new).and_return(foursquare_client)
    error = Foursquare2::APIError.new(FoursquareError.new(), nil)
    foursquare_client.stub(:venue).and_raise(error)
  end

  def stub_instagram_client(options = {})
    options[:id] ||= 'instagram_user_id'

    instagram_client = double('Instagram::Client')

    Instagram::Client.stub(:new).and_return(instagram_client)

    instagram_user = double('Hash')
    instagram_client.stub(:user).and_return(instagram_user)
    instagram_user.stub(:id).and_return(options[:id])
    instagram_user.stub(:username).and_return('eatmorsel')
    instagram_user.stub(:url).and_return("https://instagram.com/eatmorsel")

    instagram_client
  end
end
