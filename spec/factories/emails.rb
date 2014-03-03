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

FactoryGirl.define do
  factory :email do
    class_name 'Email'
    from_email 'test_from@eatmorsel.com'
    from_name 'Test From'
  end
end
