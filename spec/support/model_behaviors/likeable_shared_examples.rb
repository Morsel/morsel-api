shared_examples 'Likeable' do
  describe '.like_count' do
    it 'returns the number of likes for a Likeable' do
      likes_count = rand(3..6)
      subject.save!
      likes_count.times do
        subject.likers << FactoryGirl.create(:user)
      end
      expect(subject.like_count).to eq(likes_count)
    end
  end
end
