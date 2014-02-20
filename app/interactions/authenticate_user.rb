class AuthenticateUser < ActiveInteraction::Base
  string  :api_key

  validate :api_key_splits_into_two_components

  def execute
    split_key = api_key.split(':')

    user = User.find(split_key[0])

    if user && Devise.secure_compare(user.authentication_token, split_key[1])
      user
    else
      user.errors.add(:api_token, 'unauthorized')
    end
  end

  private

  def api_key_splits_into_two_components
    api_key.split(':').size == 2
  end
end
