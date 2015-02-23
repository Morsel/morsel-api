require 'spec_helper'

# describe 'Contact API' do
#   describe 'POST /contact contact#create' do
#     let(:endpoint) { '/contact' }
#     let(:name) { 'Zakk Wylde' }
#     let(:email) { 'zakk@bls.com' }
#     let(:subject) { 'Some Subject' }
#     let(:description) { 'Some description' }

#      it 'creates a ticket on Zendesk' do
#     #   stub_zendesk_settings
#     #   stub_zendesk_client

#       params = {
#         name: name,
#         email: email,
#         subject: subject,
#         description: description,
#         tags: ['contact-form', 'api', 'test']
#       }

#     #   CreateZendeskTicket.should_receive(:call).with(hash_including(params)).exactly(1).times.and_call_original

#       Sidekiq::Testing.inline! do
#         post_endpoint params
#       end

#       expect_success
#     end
#   end
#end

  describe 'Contact API' do
    describe "Send contact email to user" do
      let(:mail) { 
        UserMailer.send_contact_email_to_user("test",'lucas@email.com', "test subject","test descrition") 
      }
      it 'renders the subject' do
        expect(mail.subject).to eql('[Request received] test subject')
      end
      it 'renders the receiver email' do
        expect(mail.to.first).to eql('lucas@email.com')
      end
      it 'renders the email body' do
        expect(mail.body.raw_source).to eql("<p><div>##- Please type your reply above this line -##</div></p><p>Thank you for contacting Morsel. Your request has been received and is being reviewed by our support staff.</p><p>To add additional comments, reply to this email.</p><hr /><p>Hello test</p><p>#{DateTime.now}</p><p>Subject: test subject</p><p>Description: test descrition</p>")
      end
    end

    describe "Send contact email to admin " do
      let(:mail) { 
        UserMailer.send_contact_email_to_admin("test",'lucas@email.com', "test subject","test descrition") 
      }
      it 'renders the subject' do
        expect(mail.subject).to eql('lucas@email.com Have send you request')
      end
      it 'renders the receiver email' do
        expect(mail.to.first).to eql('support@eatmorsel.com')
      end
      it 'renders the email body' do
        expect(mail.body.raw_source).to eql("<p>Hello admin, test have send you message</p><p>Below are the details:</p><p>Subject: test subject</p><p>Description: test descrition</p>")
      end
  end
end