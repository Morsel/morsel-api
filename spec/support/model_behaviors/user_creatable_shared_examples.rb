shared_examples 'UserCreatable' do
  context 'resource is created' do
    before { user_creatable_object.save! }
    it 'ensures a creator role' do
      expect(user.has_role?(:creator, user_creatable_object))
    end
  end
end
