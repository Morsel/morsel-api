shared_examples 'UserCreatable' do
  context 'resource is created' do
    before { subject.save! }
    it 'ensures a creator role' do
      expect(user.has_role?(:creator, subject))
      expect(User.with_role(:creator, subject)).to include(user)
    end
  end
end
