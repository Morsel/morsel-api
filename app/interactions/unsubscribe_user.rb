class UnsubscribeUser < ActiveInteraction::Base
  string  :email

  def execute
    User.find_by(email: email).update(unsubscribed: true)
  end
end
