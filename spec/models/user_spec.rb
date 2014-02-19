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
# **`provider`**                | `string(255)`      |
# **`uid`**                     | `string(255)`      |
# **`username`**                | `string(255)`      |
# **`bio`**                     | `string(255)`      |
#

require 'spec_helper'

describe User do
  subject(:user) { FactoryGirl.build(:user) }

  it { should respond_to(:email) }
  it { should respond_to(:username) }
  it { should respond_to(:encrypted_password) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:first_name) }
  it { should respond_to(:last_name) }
  it { should respond_to(:sign_in_count) }
  it { should respond_to(:authentication_token) }
  it { should respond_to(:photo) }
  it { should respond_to(:morsel_likes_for_my_morsels_by_others_count) }
  it { should respond_to(:bio) }

  its(:authentication_token) { should be_nil }

  its(:twitter_authorizations) { should be_empty }

  its(:twitter_authorization) { should be_nil }
  its(:authorized_with_twitter?) { should be_false }
  its(:twitter_username) { should be_nil }
  its(:facebook_uid) { should be_nil }

  it { should be_valid }

  describe '.find_by_id_or_username' do
    before do
      user.save
    end

    context 'valid id is passed' do
      it 'returns the User with that id' do
        expect(User.find_by_id_or_username(user.id)).to_not be_nil
      end
    end

    context 'invalid id is passed' do
      it 'returns nil' do
        expect(User.find_by_id_or_username(123456789)).to be_nil
      end
    end

    context 'username is passed' do
      context 'valid username is passed' do
        it 'returns the User with that username' do
          expect(User.find_by_id_or_username(user.username)).to_not be_nil
        end
      end

      context 'invalid username is passed' do
        it 'returns nil' do
          expect(User.find_by_id_or_username('butt_sack')).to be_nil
        end
      end
    end
  end

  describe 'email' do
    context 'already taken' do
      before do
        user_with_same_email = user.dup
        user_with_same_email.save
      end

      it { should_not be_valid }
    end

    context 'a valid format' do
      it 'should be valid' do
        addresses = %w[ foo@bar.COM a_b-c@d.e.org turd.ferg@uson.pl a+b@cdefg.hi ]
        addresses.each do |valid_address|
          user.email = valid_address
          expect(user).to be_valid
        end
      end
    end

    context 'not a valid format' do
      it 'should not be valid' do
        addresses = %w[ turdferg turdferg@ ]
        addresses.each do |valid_address|
          user.email = valid_address
          expect(user).to_not be_valid
        end
      end
    end
  end

  describe 'username' do
    context 'already taken' do
      before do
        user_with_same_username = user.dup
        user_with_same_username.email = 'qwerfsdafdfas@asdfs.com'
        user_with_same_username.save
      end

      it { should_not be_valid }
    end

    context 'too long' do
      before { user.username = '16_char_username' }
      it { should_not be_valid }
    end

  end

  describe 'password' do
    context 'is not present' do
      before { user.password = '' }
      it { should_not be_valid }
    end

    context 'too short' do
      before { user.password = 'test123' }
      it { should_not be_valid }
    end

    context 'does not match confirmation' do
      before { user.password_confirmation = 'bar' }
      it { should_not be_valid }
    end
  end

  describe '#morsel_likes_for_my_morsels_by_others_count' do
    context 'Morsels have been liked' do
      subject(:user_with_posts) { FactoryGirl.create(:user_with_posts) }
      let(:number_of_morsel_likes) { rand(2..6) }

      before do
        morsel = user_with_posts.morsels.first
        number_of_morsel_likes.times { morsel.likers << FactoryGirl.create(:user) }
      end

      it 'returns the total number of Likes for my Morsels' do
        expect(user_with_posts.morsel_likes_for_my_morsels_by_others_count).to eq(number_of_morsel_likes)
      end

      context 'performance' do
        before do
          require 'benchmark'
        end

        it 'should take time' do
          Benchmark.realtime { user_with_posts.morsel_likes_for_my_morsels_by_others_count }.should < 0.02
        end
      end
    end
  end

  context 'persisted' do
    before { user.save }
    its(:authentication_token) { should_not be_nil }
  end

  context 'Authorizations' do
    context 'Facebook' do
      subject(:user_with_facebook_authorization) { UserSocialClientsDecorator.new(FactoryGirl.create(:user_with_facebook_authorization)) }

      its(:facebook_authorizations) { should_not be_empty }

      its(:facebook_authorization) { should_not be_nil }
      its(:authorized_with_facebook?) { should be_true }
      its(:facebook_client) { should_not be_nil }
      its(:facebook_uid) { should_not be_nil }

      describe 'facebook_uid' do
        context 'performance' do
          before do
            require 'benchmark'
          end

          it 'should take time' do
            Benchmark.realtime { user_with_facebook_authorization.facebook_uid }.should < 0.25
          end
        end
      end
    end

    context 'Twitter' do
      subject(:user_with_twitter_authorization) { UserSocialClientsDecorator.new(FactoryGirl.create(:user_with_twitter_authorization)) }

      its(:twitter_authorizations) { should_not be_empty }

      its(:twitter_authorization) { should_not be_nil }
      its(:authorized_with_twitter?) { should be_true }
      its(:twitter_client) { should_not be_nil }
      its(:twitter_username) { should_not be_nil }
      describe 'twitter_username' do
        context 'performance' do
          before do
            require 'benchmark'
          end

          it 'should take time' do
            Benchmark.realtime { user_with_twitter_authorization.twitter_username }.should < 0.25
          end
        end
      end
    end
  end
end
