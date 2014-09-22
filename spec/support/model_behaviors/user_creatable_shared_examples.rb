shared_examples 'UserCreatable' do
  context 'resource is created' do
    before { user_creatable_object.save! }
    it 'ensures a creator role' do
      expect(user.has_role?(:creator, user_creatable_object))
      expect(User.with_role(:creator, user_creatable_object)).to include(user)
      expect(user_creatable_object.roles).to eq(user.roles)
    end
  end
end
