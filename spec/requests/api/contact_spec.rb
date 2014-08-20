require 'spec_helper'

describe 'Contact API' do
  describe 'POST /contact contact#create' do
    let(:endpoint) { '/contact' }
    let(:name) { 'Zakk Wylde' }
    let(:email) { 'zakk@bls.com' }
    let(:subject) { 'Some Subject' }
    let(:description) { 'Some description' }

    it 'creates a ticket on Zendesk' do
      stub_zendesk_settings
      stub_zendesk_client

      params = {
        name: name,
        email: email,
        subject: subject,
        description: description,
        tags: ['contact-form', 'api', 'test']
      }

      CreateZendeskTicket.should_receive(:call).with(hash_including(params)).exactly(1).times.and_call_original

      Sidekiq::Testing.inline! do
        post_endpoint params
      end

      expect_success
    end
  end
end
