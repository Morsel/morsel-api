require 'spec_helper'

describe 'Authentications API Methods' do
  describe 'GET /authentications/connections authentications#connections' do
    let(:endpoint) { '/authentications/connections' }
    let(:current_user) { FactoryGirl.create(:user) }
    let(:authenticated_users_count) { rand(2..6) }

    before { authenticated_users_count.times { FactoryGirl.create(:facebook_authentication) }}

    # TODO: Test pagination
    # it_behaves_like 'TimelinePaginateable' do
    #   let(:paginateable_object_class) { User }
    #   before do
    #     paginateable_object_class.delete_all
    #     30.times { FactoryGirl.create(:facebook_authentication) }
    #   end
    # end

    # it 'returns the Users for the specified `provider` and `uids`' do
    #   get_endpoint provider: 'facebook', uids: "'123','456','789'"

    #   expect_success
    # end

    it 'returns no Users if none with the specified Authentications `uids` for the `provider` are found' do
      get_endpoint provider: 'facebook', uids: "'123','456','789'"

      expect_success
      expect(json_data.count).to be_zero
    end
  end
end
