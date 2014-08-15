class ReservedUserDecorator < SimpleDelegator
  def mrsl_set_reset_password_token
    raw, enc = Devise.token_generator.generate(User, :reset_password_token)

    self.reset_password_token   = enc
    self.reset_password_sent_at = Time.now.utc
    self.save(validate: false)
    raw
  end
end
