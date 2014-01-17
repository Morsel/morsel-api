# ## Schema Information
#
# Table name: `authorizations`
#
# ### Columns
#
# Name              | Type               | Attributes
# ----------------- | ------------------ | ---------------------------
# **`id`**          | `integer`          | `not null, primary key`
# **`provider`**    | `string(255)`      |
# **`uid`**         | `string(255)`      |
# **`user_id`**     | `integer`          |
# **`token`**       | `string(255)`      |
# **`secret`**      | `string(255)`      |
# **`name`**        | `string(255)`      |
# **`link`**        | `string(255)`      |
# **`created_at`**  | `datetime`         |
# **`updated_at`**  | `datetime`         |
#

require 'spec_helper'

describe Authorization do
  before do
    @authorization = FactoryGirl.build(:authorization)
  end

  subject { @authorization }

  it { should respond_to(:provider) }
  it { should respond_to(:uid) }
  it { should respond_to(:user_id) }
  it { should respond_to(:token) }
  it { should respond_to(:secret) }

  it { should respond_to(:user) }

  it { should be_valid }

  describe 'provider' do
    context 'does not exist' do
      before { @authorization.provider = nil }
      it { should_not be_valid }
    end

    context 'is blank' do
      before { @authorization.provider = '' }
      it { should_not be_valid }
    end

    context 'is not a valid provider' do
      before { @authorization.provider = 'taco_bell' } # Be sure to change this if Taco Bell becomes an OAuth2 provider
      it { should_not be_valid }
    end
  end

  describe 'token' do
    context 'does not exist' do
      before { @authorization.token = nil }
      it { should_not be_valid }
    end
  end

  describe 'uid' do
    context 'does not exist' do
      before { @authorization.uid = nil }
      it { should_not be_valid }
    end

    context 'is not unique' do
      before do
        authorization_with_same_uid = @authorization.dup
        authorization_with_same_uid.save
      end
      it { should_not be_valid }
    end
  end

  describe 'user' do
    context 'does not exist' do
      before { @authorization.user = nil }
      it { should_not be_valid }
    end

    context 'is not valid' do
      before { @authorization.user.email = nil }
      it { should_not be_valid }
    end
  end
end
