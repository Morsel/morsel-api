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

require 'spec_helper'

shared_examples 'an email' do
  it { should respond_to(:class_name) }
  it { should respond_to(:template_name) }
  it { should respond_to(:from_email) }
  it { should respond_to(:from_name) }
  it { should respond_to(:stop_sending) }

  its(:stop_sending) { should be_false }

  it { expect(Email.default_from_email).to eq('support@eatmorsel.com') }
  it { expect(Email.default_from_name).to eq('Morsel') }

  it { should be_valid }

  its(:mandrill_hash) { should eq(expected_mandrill_hash) }
end

describe Email do
  it_behaves_like 'an email' do
    subject(:email) { FactoryGirl.create(:email) }
    let(:expected_mandrill_hash) { { :from=>email.from_email,
                                    :from_name=>email.from_name,
                                    :template=>nil,
                                    :subject=>nil,
                                    :to=> {
                                      :email=>nil,
                                      :name=>nil
                                    },
                                    :bcc=>Settings['developer_email'],
                                    :vars=> {
                                      :email_subject=>nil,
                                      :email_teaser=>nil,
                                      :email_title=>nil,
                                      :email_subtitle=>nil,
                                      :email_body=>nil,
                                      :current_year=>Time.now.year,
                                      :email_reason=>nil
                                    },
                                    :metadata=> {
                                      :email_id=>email.id,
                                      :user_id=>nil
                                    }
                                  } }
  end

  it { expect{ Email.default_template_name }.to raise_exception }
  it { expect{ Email.default_subject }.to raise_exception }
  it { expect(Email.default_teaser).to be_nil }
  it { expect{ Email.default_title }.to raise_exception }
  it { expect{ Email.default_subtitle }.to raise_exception }
  it { expect{ Email.default_body }.to raise_exception }
  it { expect(Email.default_reason).to be_nil }


  describe "._email" do
    let(:user) { FactoryGirl.create(:user) }
    it 'should raise an exception since there is no default template name set' do
      expect{Email._email(user.email, user.full_name)}.to raise_exception
    end
  end
end

describe Emails::UsernameReservedEmail do
  it_behaves_like 'an email' do
    subject(:email) { FactoryGirl.create(:email) }
    let(:expected_mandrill_hash) { { :from=>email.from_email,
                                    :from_name=>email.from_name,
                                    :template=>nil,
                                    :subject=>nil,
                                    :to=> {
                                      :email=>nil,
                                      :name=>nil
                                    },
                                    :bcc=>Settings['developer_email'],
                                    :vars=> {
                                      :email_subject=>nil,
                                      :email_teaser=>nil,
                                      :email_title=>nil,
                                      :email_subtitle=>nil,
                                      :email_body=>nil,
                                      :current_year=>Time.now.year,
                                      :email_reason=>nil
                                    },
                                    :metadata=> {
                                      :email_id=>email.id,
                                      :user_id=>nil
                                    }
                                  } }
  end

  it { expect(Emails::UsernameReservedEmail.default_template_name).to eq('Notification') }
  it { expect(Emails::UsernameReservedEmail.default_subject).to eq('Your Morsel Username Reservation') }
  it { expect(Emails::UsernameReservedEmail.default_teaser).to eq('Thanks for reserving *|USER_USERNAME|* on Morsel.') }
  it { expect(Emails::UsernameReservedEmail.default_title).to eq('Hey There!') }
  it { expect(Emails::UsernameReservedEmail.default_subtitle).to eq('Thanks for reserving <b>*|USER_USERNAME|*</b> on Morsel.') }
  it { expect(Emails::UsernameReservedEmail.default_body).to eq("<p>You're one step closer to the most amazing storytelling platform powered by chefs, mixologists, sommeliers and more. We'll let you know as soon as we're ready for you!</p><p>Bon Appetit!</p><p>Team Morsel</p>") }
  it { expect(Emails::UsernameReservedEmail.default_reason).to eq("You're receiving this email because you reserved a username with us.") }


  describe ".email" do
    let(:user) { FactoryGirl.create(:user) }
    it 'should find or create the email' do
      e = Emails::UsernameReservedEmail.email(user)

      expect(e).to_not be_nil
      expect(e.teaser).to eq("Thanks for reserving #{user.username} on Morsel.")
      expect(e.subtitle).to eq("Thanks for reserving <b>#{user.username}</b> on Morsel.")
      expect(e.user.username).to eq(user.username)
    end
  end
end
