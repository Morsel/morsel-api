require 'spec_helper'

describe 'Subscribers API' do
  describe 'POST /subscribers subscribers#create' do
    it 'creates a new Subscriber' do
      post '/subscribers',  format: :json,
                            subscriber: {
                              user_id: 1,
                              email: 'foo@bar.com',
                              url: 'https://www.eatmorsel.com/marty',
                              source_url: 'https://twitter.com/martytrzpit',
                              role: 'chef' }

      expect(response).to be_success
    end
  end
end
