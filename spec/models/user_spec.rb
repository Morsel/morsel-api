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
# **`photo`**                   | `string(255)`      |
# **`photo_content_type`**      | `string(255)`      |
# **`photo_file_size`**         | `string(255)`      |
# **`photo_updated_at`**        | `datetime`         |
# **`title`**                   | `string(255)`      |
#

require 'spec_helper'

describe User do
  before do
    @user = FactoryGirl.build(:user)
  end

  subject { @user }

  it { should respond_to(:email) }
  it { should respond_to(:encrypted_password) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:first_name) }
  it { should respond_to(:last_name) }
  it { should respond_to(:sign_in_count) }
  it { should respond_to(:authentication_token) }
  it { should respond_to(:photo) }

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
        addresses = %w[ turdferg turdferg@ ]
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

  describe 'authentication_token' do
    describe 'unsaved User' do
      it 'should not exist' do
        expect(@user.authentication_token).to be_nil
      end
    end
    describe 'saved User' do
      before { @user.save }
      it 'should exist' do
        expect(@user.authentication_token).to_not be_nil
      end
    end
  end
end
