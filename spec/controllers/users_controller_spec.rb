require 'spec_helper'

describe UsersController do
  describe UsersController::UserParams do
    describe '.build' do
      it 'cleans the params' do
        params = ActionController::Parameters.new(user: { email: 'turdferg@eatmorsel.com' })
        user_params = UsersController::UserParams.build(params)
        expect(user_params).to eq({ email: 'turdferg@eatmorsel.com' }.with_indifferent_access)
      end
    end
  end

# before (:each) do
#   @user = User.create!({
#     :first_name => 'Turd',
#     :last_name => 'Ferguson',
#     :email => 'turdferg@eatmorsel.com',
#     :password => 'test1234',
#     :password_confirmation => 'test1234'
#     })
#   sign_in @user
# end

end
