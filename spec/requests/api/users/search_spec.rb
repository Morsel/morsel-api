require_relative '_spec_helper'

describe 'GET /users/search users#search' do
  let(:endpoint) { '/users/search' }

  context 'promoted' do
    let(:promoted_users_count) { rand(2..6) }
    before do
      promoted_users_count.times { FactoryGirl.create(:user, promoted: true) }
      rand(1..3).times { FactoryGirl.create(:user) }
    end

    it_behaves_like 'TimelinePaginateable' do
      let(:paginateable_object_class) { User }
      let(:additional_params) {{ user: { promoted: true }}}

      before do
        paginateable_object_class.delete_all
        30.times { FactoryGirl.create(:user, promoted: true) }
      end
    end
  end
end
