require 'spec_helper'

describe CreateZendeskTicket do
  let(:service_class) { CreateZendeskTicket }

  let(:subject) { 'Zendesk Ticket Subject!' }
  let(:description) { 'Zendesk Ticket description' }

  it 'should create a ticket' do
    stub_zendesk_settings
    stub_zendesk_client

    call_service ({
      subject: subject,
      description: description
    })

    expect_service_success
    expect(service_response).to_not eq(nil)
  end

  context 'no subject specified' do
    it 'throws an error' do
      call_service

      expect_service_failure
    end
  end
end
