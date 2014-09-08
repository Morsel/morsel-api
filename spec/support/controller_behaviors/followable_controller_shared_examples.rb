shared_examples 'FollowableController' do
  describe 'POST /followable/:id/follow' do
    let(:endpoint) { "#{followable_route}/#{followable.id}/follow" }

    it 'follows the Followable' do
      post_endpoint

      expect_success
      expect(followable.followers).to include(current_user)
    end

    it 'creates an Activity and Notification' do
      Sidekiq::Testing.inline! { post_endpoint }

      expect_success

      activity = current_user.activities.last
      expect(activity).to_not be_nil
      expect(activity.creator).to eq(current_user)
      expect(activity.subject).to eq(followable)
      expect(activity.action).to eq(Follow.last)
    end

    context 'already follows the Followable' do
      before do
        post_endpoint
      end

      it 'returns an error' do
        post_endpoint

        expect_failure
        expect_status 422
        expect(json_errors[followable.class.base_class.to_s.underscore].first).to eq('already followed')
      end
    end

    context 'followed then unfollowed the Followable' do
      before do
        post_endpoint
        delete_endpoint
      end

      it 'follows the Followable for the current_user' do
        post_endpoint

        expect_success
        expect_status 201
        expect(followable.followers).to include(current_user)
      end
    end
  end

  describe 'DELETE /followable/:id/follow' do
    let(:endpoint) { "#{followable_route}/#{followable.id}/follow" }

    context 'Follow exists' do
      before { followable.followers << current_user }
      it 'soft deletes the Follow' do
        delete_endpoint

        expect_success
        expect(followable.followers).to_not include(current_user)
      end
    end

    context 'Follow doesn\'t exist' do
      it 'returns an error' do
        delete_endpoint

        expect_failure
        expect(json_errors[followable.class.base_class.to_s.underscore].first).to eq('not followed')
      end
    end
  end

  describe 'GET /followable/:id/followers' do
    let(:endpoint) { "#{followable_route}/#{followable.id}/followers" }
    let(:followers_count) { rand(2..6) }

    before { followers_count.times { FactoryGirl.create(:follow, followable: followable) }}

    it_behaves_like 'TimelinePaginateable' do
      let(:paginateable_object_class) { Follow }
      let(:paginateable_key) { :created_at }
      let(:paginateable_response_key) { :followed_at }

      before do
        paginateable_object_class.delete_all
        30.times { |i| FactoryGirl.create(:follow, followable: followable, created_at:Time.at(i) + 1000) }
      end
    end

    it 'returns the Users that are following the Followable' do
      get_endpoint

      expect_success

      expect_json_data_count followers_count
      expect_first_json_data_eq('followed_at' => Follow.last.created_at.as_json)
    end

    context 'last User unfollowed Followable' do
      before { Follow.last.destroy }

      it 'returns one less follower' do
        get_endpoint

        expect_success
        expect_json_data_count(followers_count - 1)
      end
    end
  end
end
