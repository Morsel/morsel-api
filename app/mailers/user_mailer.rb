class UserMailer < ActionMailer::Base
  include Devise::Mailers::Helpers

  def reset_password_instructions(record, token, opts = {})
    @token = token
    devise_mail(record, :reset_password_instructions, opts)
  end

  def reserved_username_instructions(record, token, opts = {})
    @token = token
    devise_mail(record, :reserved_username_instructions, opts.merge(subject: "#{record.username}. You're in. Your Morsel account is waiting"))
  end

  def reserved_username_reminder(record, token, opts = {})
    @token = token
    devise_mail(record, :reserved_username_reminder, opts.merge(subject: "#{record.username}. You're in! Your Morsel account is waiting", from: 'Ellen Malloy <support@eatmorsel.com>'))
  end
end
