shared_examples 'Commentable' do
  describe '.comments_count' do
    let(:comments_count) { rand(3..6) }
    before do
      subject.save! unless subject.persisted?
      comments_count.times do
        FactoryGirl.create(:comment, commentable: subject)
      end
    end

    it 'returns the number of comments for a Commentable' do
      expect(subject.reload.comments_count).to eq(comments_count)
    end
  end
end
