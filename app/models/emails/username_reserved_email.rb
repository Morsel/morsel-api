# ## Schema Information
#
# Table name: `emails`
#
# ### Columns
#
# Name                 | Type               | Attributes
# -------------------- | ------------------ | ---------------------------
# **`id`**             | `integer`          | `not null, primary key`
# **`class_name`**     | `string(255)`      |
# **`template_name`**  | `string(255)`      |
# **`from_email`**     | `string(255)`      |
# **`from_name`**      | `string(255)`      |
# **`stop_sending`**   | `boolean`          | `default(FALSE)`
# **`created_at`**     | `datetime`         |
# **`updated_at`**     | `datetime`         |
#

module Emails
  class UsernameReservedEmail < Email
    def self.email(user = nil)
      email = _email(user)

      email.subject = default_subject
      email.teaser = default_teaser.gsub('*|USER_USERNAME|*', user.username)
      email.title = default_title
      email.subtitle = default_subtitle.gsub('*|USER_USERNAME|*', user.username)
      email.body = default_body
      email.reason = default_reason

      email
    end

    def self.default_template_name
      'Notification'
    end

    def self.default_subject
      'Your Morsel Username Reservation'
    end

    def self.default_teaser
      'Thanks for reserving *|USER_USERNAME|* on Morsel.'
    end

    def self.default_title
      'Hey There!'
    end

    def self.default_subtitle
      'Thanks for reserving <b>*|USER_USERNAME|*</b> on Morsel.'
    end

    def self.default_body
      "<p>You're one step closer to the most amazing storytelling platform powered by chefs, mixologists, sommeliers and more. We'll let you know as soon as we're ready for you!</p><p>Bon Appetit!</p><p>Team Morsel</p>"
    end

    def self.default_reason
      "You're receiving this email because you reserved a username with us."
    end
  end
end
