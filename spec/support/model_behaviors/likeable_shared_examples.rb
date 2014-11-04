shared_examples 'Likeable' do
  describe '.likes_count' do
    let(:likes_count) { rand(3..6) }
    before do
      subject.save! unless subject.persisted?
      likes_count.times do
        FactoryGirl.create(:like, likeable: subject)
      end
    end

    it 'returns the number of likes for a Likeable' do
      expect(subject.reload.likes_count).to eq(likes_count)
    end
  end
end
