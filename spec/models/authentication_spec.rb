# ## Schema Information
#
# Table name: `authentications`
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

describe Authentication do
  subject(:authentication) { FactoryGirl.build(:facebook_authentication) }

  it { should respond_to(:provider) }
  it { should respond_to(:uid) }
  it { should respond_to(:user_id) }
  it { should respond_to(:token) }
  it { should respond_to(:secret) }

  it { should respond_to(:user) }

  it { should be_valid }

  it_behaves_like 'UserCreatable' do
    let(:user_creatable_object) { FactoryGirl.build(:facebook_authentication) }
    let(:user) { user_creatable_object.user }
  end

  describe 'provider' do
    context 'does not exist' do
      before { authentication.provider = nil }
      it { should_not be_valid }
    end

    context 'is blank' do
      before { authentication.provider = '' }
      it { should_not be_valid }
    end

    context 'is not a valid provider' do
      before { authentication.provider = 'taco_bell' } # Be sure to change this if Taco Bell becomes an OAuth2 provider
      it { should_not be_valid }
    end
  end

  describe 'secret' do
    context 'does not exist' do
      before { authentication.secret = nil }
      it { should be_valid }

      context 'Twitter' do
        before { authentication.provider = 'twitter' }
        it { should_not be_valid }
      end
    end
  end

  describe 'token' do
    context 'does not exist' do
      before { authentication.token = nil }
      it { should_not be_valid }
    end
  end

  describe 'uid' do
    context 'does not exist' do
      before { authentication.uid = nil }
      it { should_not be_valid }
    end

    context 'is not unique' do
      before do
        authentication_with_same_uid = authentication.dup
        authentication_with_same_uid.save
      end
      it { should_not be_valid }
    end
  end

  describe 'user' do
    context 'does not exist' do
      before { authentication.user = nil }
      it { should_not be_valid }
    end
  end
end
