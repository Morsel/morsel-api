shared_examples 'CommentableController' do
  describe 'GET /commentable/:id/comments comments#index' do
    let(:endpoint) { "#{commentable_route}/#{commentable.id}/comments" }
    let(:comments_count) { rand(2..6) }

    before { comments_count.times { FactoryGirl.create(:comment, commentable: commentable) }}

    it 'returns a list of Comments for the Commentable' do
      get_endpoint

      expect_success
      expect_json_data_count comments_count

      first_comment = json_data.first
      expect(first_comment['creator']).to_not be_nil
      expect(first_comment['commentable_id']).to eq(commentable.id)
    end

    it_behaves_like 'TimelinePaginateable' do
      let(:paginateable_object_class) { Comment }
      before do
        paginateable_object_class.delete_all
        30.times { FactoryGirl.create(:comment, commentable: commentable) }
      end
    end
  end

  describe 'POST /commentable/:id/comments comments#create' do
    let(:endpoint) { "#{commentable_route}/#{commentable.id}/comments" }

    it 'creates a Comment for the Item' do
      post_endpoint comment: {
                      description: 'Drop it like it\'s hot.'
                    }

      expect_success
      expect(json_data['id']).to_not be_nil

      new_comment = Comment.find(json_data['id'])
      expect_json_data_eq({
        'id' => new_comment.id,
        'description' => new_comment.description,
        'commentable_id' => new_comment.commentable.id,
        'creator' => {
          'id' => current_user.id
        }
      })
      expect(current_user.has_role?(:creator, new_comment))
    end

    it 'creates an Activity and Notification' do
      Sidekiq::Testing.inline! do
        post_endpoint comment: {
                        description: 'Drop it like it\'s hot.'
                      }
      end

      expect_success

      activity = current_user.activities.last
      expect(activity).to_not be_nil
      expect(activity.creator).to eq(current_user)
      expect(activity.subject).to eq(commentable)
      expect(activity.action).to eq(Comment.last)

      notification = commentable.creator.notifications.last
      expect(notification).to_not be_nil
      expect(notification.user).to eq(commentable.creator)
      expect(notification.payload).to eq(activity)

      # TODO: Make this not Item-specific
      expect(notification.message).to eq("#{current_user.full_name_with_username} commented on '#{commentable.morsel_title_with_description}'")
    end

    context 'missing Commentable' do
      let(:endpoint) { "/#{commentable_route}/0/comments" }
      it 'should fail' do
        post_endpoint comment: {
                        description: 'Drop it like it\'s hot.'
                      }

        expect_failure
      end
    end
  end

  describe 'DELETE /commentable/:id/comments/{:comment_id} comments#destroy' do
    context 'current_user is the Comment creator' do
      let(:endpoint) { "#{commentable_route}/#{commentable.id}/comments/#{comment.id}" }
      let(:comment) { FactoryGirl.create(:comment, commentable: commentable, commenter: current_user) }

      it 'soft deletes the Comment' do
        delete_endpoint
        expect_success
        expect(Comment.find_by(id: comment.id)).to be_nil
      end
    end

    context 'current_user is the Item creator' do
      let(:endpoint) { "#{commentable_route}/#{commentable.id}/comments/#{comment.id}" }
      let(:comment) { FactoryGirl.create(:comment, commentable: FactoryGirl.create(:item, creator: current_user)) } # TODO: Make this not Item-specific

      it 'soft deletes the Comment' do
        delete_endpoint

        expect_success
        expect(Comment.find_by(id: comment.id)).to be_nil
      end
    end

    context 'current_user is not the Comment or Item creator' do
      let(:endpoint) { "#{commentable_route}/#{commentable.id}/comments/#{comment.id}" }
      let(:comment) { FactoryGirl.create(:comment, commentable: commentable) }

      it 'does NOT soft delete the Comment' do
        delete_endpoint

        expect_failure
        expect(Comment.find_by(id: comment.id)).to_not be_nil
        expect(json_errors['api'].first).to eq('Not authorized to delete Comment')
      end
    end

    context 'Comment doesn\'t exist' do
      let(:endpoint) { "#{commentable_route}/#{commentable.id}/comments/0" }

      it 'returns an error' do
        delete_endpoint

        expect_failure
        expect(json_errors['base']).to include('Record not found')
      end
    end
  end
end
