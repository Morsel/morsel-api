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
# **`provider`**                | `string(255)`      |
# **`uid`**                     | `string(255)`      |
# **`username`**                | `string(255)`      |
# **`bio`**                     | `string(255)`      |
# **`active`**                  | `boolean`          | `default(TRUE)`
# **`verified_at`**             | `datetime`         |
# **`industry`**                | `string(255)`      |
# **`photo_processing`**        | `boolean`          |
# **`staff`**                   | `boolean`          | `default(FALSE)`
# **`deleted_at`**              | `datetime`         |
# **`promoted`**                | `boolean`          | `default(FALSE)`
# **`settings`**                | `hstore`           | `default({})`
# **`professional`**            | `boolean`          | `default(FALSE)`
# **`password_set`**            | `boolean`          | `default(TRUE)`
# **`drafts_count`**            | `integer`          | `default(0), not null`
# **`followed_users_count`**    | `integer`          | `default(0), not null`
# **`followers_count`**         | `integer`          | `default(0), not null`
#

require 'spec_helper'

describe User do
  subject(:user) { FactoryGirl.build(:user) }

  it_behaves_like 'Followable'
  it_behaves_like 'Paranoia'
  it_behaves_like 'Timestamps'

  it { should respond_to(:email) }
  it { should respond_to(:username) }
  it { should respond_to(:encrypted_password) }
  it { should respond_to(:password) }
  it { should respond_to(:first_name) }
  it { should respond_to(:last_name) }
  it { should respond_to(:sign_in_count) }
  it { should respond_to(:authentication_token) }
  it { should respond_to(:photo) }
  it { should respond_to(:follower_count) }
  it { should respond_to(:followed_user_count) }
  it { should respond_to(:bio) }
  it { should respond_to(:password_set) }
  it { should respond_to(:settings) }

  its(:authentication_token) { should be_nil }
  its(:password_set) { should be_true }
  its(:remote_notifications) { should be_empty }

  it { should be_valid }

  context 'following Users' do
    let(:followed_users_count) { rand(3..6) }
    before do
      subject.save! unless subject.persisted?
      followed_users_count.times do
        FactoryGirl.create(:user_follow, follower: subject)
      end
    end

    let(:followed_user) { subject.followed_users.last }

    it 'returns `true` for following_user?' do
      expect(subject.following_user?(followed_user)).to be_true
    end

    describe '.followed_users_count' do
      it 'returns the number of followed Users' do
        expect(subject.reload.followed_users_count).to eq(followed_users_count)
      end
    end
  end

  context 'following a Place' do
    let(:followed_place) { FactoryGirl.create(:place) }
    before { subject.followed_places << followed_place }

    it 'returns `true` for following_place?' do
      expect(subject.following_place?(followed_place)).to be_true
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

    context 'reserved path' do
      before { user.username = ReservedPaths.non_username_paths.sample }
      it { should_not be_valid }
    end

    context 'can be one character' do
      before { user.username = 'a' }
      it { should be_valid }
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

    context 'too long' do
      before { user.password = Faker::Lorem.characters(130) }
      it { should_not be_valid }
    end
  end

  context :saved do
    before { user.save }
    its(:authentication_token) { should_not be_nil }
    its(:auto_follow?) { should be_true }
  end

  context 'Authorizations' do
    context 'Facebook' do
      subject(:chef_with_facebook_authentication) { FacebookAuthenticatedUserDecorator.new(FactoryGirl.create(:chef_with_facebook_authentication)) }

      its(:facebook_authentications) { should_not be_empty }

      its(:facebook_authentication) { should_not be_nil }
      its(:authenticated_with_facebook?) { should be_true }
      its(:facebook_client) { should_not be_nil }
      its(:facebook_uid) { should_not be_nil }
    end

    context 'Twitter' do
      subject(:chef_with_twitter_authentication) { TwitterAuthenticatedUserDecorator.new(FactoryGirl.create(:chef_with_twitter_authentication)) }

      its(:twitter_authentications) { should_not be_empty }

      its(:twitter_authentication) { should_not be_nil }
      its(:authenticated_with_twitter?) { should be_true }
      its(:twitter_client) { should_not be_nil }
      its(:twitter_username) { should_not be_nil }
    end
  end

  context 'Email' do
    describe '#send_reserved_username_email' do
      let(:email_user) { EmailUserDecorator.new(user) }

      before do
        email_user.save
      end

      it 'creates the EmailWorker job' do
        expect {
          email_user.send_reserved_username_email
        }.to change(EmailWorker.jobs, :size).by(1)
      end

      it 'sends the Username Reserved email' do
        Sidekiq::Testing.inline! { email_user.send_reserved_username_email }
        mail = MandrillMailer.deliveries.first
        username_reserved_email = Emails::UsernameReservedEmail.email(email_user)

        expect(mail).to_not be_nil
        expect(mail.message['from_email']).to eq('support@eatmorsel.com')
        expect(mail.message['from_name']).to eq('Morsel')

        expect(mail.template_name).to eq(username_reserved_email.template_name)
        expect(mail.message['to'].first[:email]).to eq(email_user.email)
        expect(mail.message['to'].first[:name]).to eq(email_user.full_name)
        expect(mail.message['from_email']).to eq(username_reserved_email.from_email)
        expect(mail.message['from_name']).to eq(username_reserved_email.from_name)

        vars = mail.message['global_merge_vars'].map { |v| { v['name'] => v['content'] }}.reduce(Hash.new, :merge)
        %w(subject teaser title subtitle body reason).each do |key|
          expect(vars["email_#{key}".to_sym]).to eq(username_reserved_email.send(key))
        end
        expect(vars[:current_year]).to eq(Time.now.year)
      end

      context 'stop_sending? is set to true' do
        it 'does NOT send the Username Reserved email' do
          username_reserved_email = Emails::UsernameReservedEmail.email(email_user)
          username_reserved_email.stop_sending = true
          username_reserved_email.save

          Sidekiq::Testing.inline! { email_user.send_reserved_username_email }
          expect(MandrillMailer.deliveries).to be_empty
        end
      end

      context 'user is unsubscribed' do
        before do
          email_user.unsubscribed = true
        end
        it 'does NOT send the Username Reserved email' do
          Sidekiq::Testing.inline! { email_user.send_reserved_username_email }
          expect(MandrillMailer.deliveries).to be_empty
        end
      end
    end
  end
end
