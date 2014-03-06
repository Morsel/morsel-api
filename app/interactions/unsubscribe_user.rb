class UnsubscribeUser < ActiveInteraction::Base
  string  :email

  def execute
    user = User.find_by(email: email)
    user.update(unsubscribed: true)
    errors.merge!(user.errors)
  end
end
