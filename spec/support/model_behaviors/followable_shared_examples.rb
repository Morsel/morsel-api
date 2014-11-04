shared_examples 'Followable' do
  describe '.followers_count' do
    let(:followers_count) { rand(3..6) }
    before do
      subject.save! unless subject.persisted?
      followers_count.times do
        FactoryGirl.create(:follow, followable: subject)
      end
    end

    it 'returns the number of followers for a Followable' do
      expect(subject.reload.followers_count).to eq(followers_count)
    end
  end
end
