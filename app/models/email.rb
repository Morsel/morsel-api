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

class Email < ActiveRecord::Base
  attr_accessor :user, :subject, :teaser, :title, :subtitle, :body, :reason

  def self.default_from_email
    'support@eatmorsel.com'
  end

  def self.default_from_name
    'Morsel'
  end

  def self.default_template_name
    raise 'Invalid Template Name'
  end

  def self.default_subject
    raise 'Invalid Subject'
  end

  def self.default_teaser
    nil
  end

  def self.default_title
    raise 'Invalid Title'
  end

  def self.default_subtitle
    raise 'Invalid Subtitle'
  end

  def self.default_body
    raise 'Invalid Body'
  end

  def self.default_reason
    nil
  end

  def mandrill_hash
    {
      from: from_email,
      from_name: from_name,
      template: template_name,
      subject: subject,
      to: {
        email: user ? user.email : nil,
        name: user ? user.full_name : nil
      },
      bcc: Settings['developer_email'],
      vars: {
        email_subject: subject,
        email_teaser: teaser,
        email_title: title,
        email_subtitle: subtitle,
        email_body: body,
        current_year: Time.now.year,
        email_reason: reason,
        unsub: "#{Settings.morsel.web_url}/unsubscribe"
      },
      metadata: {
        email_id: id,
        user_id: user ? user.id : nil
      }
    }
  end

  private

  def self._email(user = nil)
    email = find_or_create_by(class_name: to_s) do |e|
      e.class_name = to_s
      e.template_name = default_template_name
      e.from_email = default_from_email
      e.from_name = default_from_name
    end

    email.user = user
    email
  end
end
