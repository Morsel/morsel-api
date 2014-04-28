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
# **`active`**                  | `boolean`          | `default(TRUE)`
# **`verified_at`**             | `datetime`         |
# **`industry`**                | `string(255)`      |
# **`unsubscribed`**            | `boolean`          | `default(FALSE)`
# **`photo_processing`**        | `boolean`          |
# **`staff`**                   | `boolean`          | `default(FALSE)`
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
  it { should respond_to(:liked_items_count) }
  it { should respond_to(:follower_count) }
  it { should respond_to(:followed_users_count) }
  it { should respond_to(:bio) }

  its(:authentication_token) { should be_nil }

  it { should be_valid }

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

  describe '#liked_items_count' do
    context 'items have been liked' do
      subject(:user_with_morsels) { FactoryGirl.create(:user_with_morsels) }
      let(:number_of_likes) { rand(2..6) }

      before { number_of_likes.times { Like.create(likeable: FactoryGirl.create(:item_with_creator), liker: user_with_morsels) }}

      it 'returns the total number of Likes for the user' do
        expect(user_with_morsels.liked_items_count).to eq(number_of_likes)
      end
    end
  end

  context 'persisted' do
    before { user.save }
    its(:authentication_token) { should_not be_nil }

    describe 'admin' do
      context 'is true' do
        before { user.update(admin: true) }
        it 'adds the :admin role' do
          expect(user.has_role?(:admin)).to be_true
        end
        it 'removed the :admin role if admin is set to false' do
          user.update(admin: false)
          expect(user.has_role?(:admin)).to be_false
        end
      end
    end

    describe 'staff' do
      context 'is true' do
        before { user.update(staff: true) }
        it 'adds the :staff role' do
          expect(user.has_role?(:staff)).to be_true
        end
        it 'removed the :staff role if staff is set to false' do
          user.update(staff: false)
          expect(user.has_role?(:staff)).to be_false
        end
      end
    end

    describe 'industry' do
      context 'chef' do
        before { user.update(industry: 'chef') }
        it 'adds the :chef role' do
          expect(user.has_role?(:chef)).to be_true
        end
      end

      context 'media' do
        before do
          user.update(industry: 'media')
        end
        it 'adds the :media role' do
          expect(user.has_role?(:media)).to be_true
        end
      end
    end
  end

  context 'Authorizations' do
    context 'Facebook' do
      subject(:chef_with_facebook_authorization) { FacebookUserDecorator.new(FactoryGirl.create(:chef_with_facebook_authorization)) }

      its(:facebook_authorizations) { should_not be_empty }

      its(:facebook_authorization) { should_not be_nil }
      its(:authorized_with_facebook?) { should be_true }
      its(:facebook_client) { should_not be_nil }
      its(:facebook_uid) { should_not be_nil }
    end

    context 'Twitter' do
      subject(:chef_with_twitter_authorization) { TwitterUserDecorator.new(FactoryGirl.create(:chef_with_twitter_authorization)) }

      its(:twitter_authorizations) { should_not be_empty }

      its(:twitter_authorization) { should_not be_nil }
      its(:authorized_with_twitter?) { should be_true }
      its(:user_twitter_client) { should_not be_nil }
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
