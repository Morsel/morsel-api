# ## Schema Information
#
# Table name: `users`
#
# ### Columns
#
# Name                          | Type               | Attributes
# ----------------------------- | ------------------ | ---------------------------
# **`id`**                      | `integer`          | `not null, primary key`
# **`email`**                   | `string(255)`      | `default(""), not null`
# **`encrypted_password`**      | `string(255)`      | `default(""), not null`
# **`reset_password_token`**    | `string(255)`      |
# **`reset_password_sent_at`**  | `datetime`         |
# **`remember_created_at`**     | `datetime`         |
# **`sign_in_count`**           | `integer`          | `default(0), not null`
# **`current_sign_in_at`**      | `datetime`         |
# **`last_sign_in_at`**         | `datetime`         |
# **`current_sign_in_ip`**      | `string(255)`      |
# **`last_sign_in_ip`**         | `string(255)`      |
# **`created_at`**              | `datetime`         |
# **`updated_at`**              | `datetime`         |
# **`first_name`**              | `string(255)`      |
# **`last_name`**               | `string(255)`      |
# **`admin`**                   | `boolean`          | `default(FALSE), not null`
# **`authentication_token`**    | `string(255)`      |
# **`profile`**                 | `string(255)`      |
# **`profile_content_type`**    | `string(255)`      |
# **`profile_file_size`**       | `string(255)`      |
# **`profile_updated_at`**      | `datetime`         |
#

require 'spec_helper'

describe User do
  before do
    @user = User.new(email: 'turdferg@eatmorsel.com',
                     password: 'test1234',
                     password_confirmation: 'test1234')
  end

  subject { @user }

  it { should respond_to(:email) }
  it { should respond_to(:encrypted_password) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }

  it { should be_valid }

  describe 'email' do
    describe 'is already taken' do
      before do
        user_with_same_email = @user.dup
        user_with_same_email.save
      end

      it { should_not be_valid }
    end

    describe 'is a valid format' do
      it 'should be valid' do
        addresses = %w[ foo@bar.COM a_b-c@d.e.org turd.ferg@uson.pl a+b@cdefg.hi ]
        addresses.each do |valid_address|
          @user.email = valid_address
          expect(@user).to be_valid
        end
      end
    end

    describe 'is not a valid format' do
      it 'should not be valid' do
        addresses = %w[ turdferg turdferg@ foo@bar foo@bar. foo@bar.a1b2
                        foo@bar..co.uk foo@bar,com foo.bar foo@bar+baz.com a@b.c ]
        addresses.each do |valid_address|
          @user.email = valid_address
          expect(@user).to_not be_valid
        end
      end
    end
  end

  describe 'password' do
    describe 'is not present' do
      before { @user.password = '' }
      it { should_not be_valid }
    end

    describe 'is too short' do
      before { @user.password = 'test123' }
      it { should_not be_valid }
    end

    describe 'does not match confirmation' do
      before { @user.password_confirmation = 'bar' }
      it { should_not be_valid }
    end
  end
end
