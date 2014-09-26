shared_examples 'LikeableController' do
  describe 'POST /likeable/:id/like' do
    let(:endpoint) { "#{likeable_route}/#{likeable.id}/like" }

    context 'authenticated' do
      let(:current_user) { FactoryGirl.create(:user) }

      it 'likes the Likeable' do
        post_endpoint

        expect_success
        expect(likeable.likers).to include(current_user)
      end

      it 'creates an Activity and Notification' do
        Sidekiq::Testing.inline! { post_endpoint }

        expect_success

        activity = current_user.activities.last
        expect(activity).to_not be_nil
        expect(activity.creator).to eq(current_user)
        expect(activity.recipient).to eq(likeable.creator)
        expect(activity.subject).to eq(likeable)
        expect(activity.action).to eq(Like.last)

        notification = likeable.creator.notifications.last
        expect(notification).to_not be_nil
        expect(notification.user).to eq(likeable.creator)
        expect(notification.payload).to eq(activity)

        # TODO: Make this not Item-specific
        expect(notification.message).to eq("#{current_user.full_name} (#{current_user.username}) liked #{likeable.morsel_title_with_description}".truncate(Settings.morsel.notification_length, separator: ' ', omission: '... '))
      end

      context 'already likes the Likeable' do
        before { likeable.likers << current_user }

        it 'returns an error' do
          post_endpoint

          expect_failure
          expect(response.status).to eq(422)
          expect(json_errors[likeable.class.base_class.to_s.underscore].first).to eq('already liked')
        end
      end

      context 'liked then unliked the Likeable' do
        before do
          likeable.likers << current_user
          likeable.likers.destroy(current_user)
        end

        it 'likes the Likeable for the current_user' do
          post_endpoint

          expect_success
          expect(response.status).to eq(201)
          expect(likeable.likers).to include(current_user)
        end
      end
    end
  end

  describe 'DELETE /likeable/:id/like likes#destroy' do
    let(:endpoint) { "#{likeable_route}/#{likeable.id}/like" }

    context 'authenticated' do
      let(:current_user) { FactoryGirl.create(:user) }

      context 'current_user has liked Likeable' do
        before { Like.create(likeable: likeable, user: current_user) }

        it 'soft deletes the Like' do
          delete_endpoint

          expect_success
          expect(likeable.likers).to_not include(current_user)
        end
      end

      context 'current_user has NOT liked Likeable' do
        it 'does NOT soft delete the Like' do
          delete_endpoint

          expect_failure
          expect(response.status).to eq(422)
          expect(json_errors[likeable.class.base_class.to_s.underscore].first).to eq('not liked')
        end
      end

      context 'current_user is NOT Like creator' do
        before { Like.create(likeable: likeable, user: FactoryGirl.create(:user)) }
        it 'should NOT be authorized' do
          delete_endpoint

          expect_failure
        end
      end
    end
  end

  describe 'GET /likeable/:id/likers items#likers' do
    let(:endpoint) { "#{likeable_route}/#{likeable.id}/likers" }
    let(:likers_count) { rand(2..6) }

    before { likers_count.times { FactoryGirl.create(:like, likeable: likeable) }}

    it_behaves_like 'TimelinePaginateable' do
      let(:paginateable_object_class) { User }
      before do
        paginateable_object_class.delete_all
        30.times { FactoryGirl.create(:like, likeable: likeable) }
      end
    end
  end
end
