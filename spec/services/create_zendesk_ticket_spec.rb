require 'spec_helper'

describe CreateZendeskTicket do
  let(:service_class) { described_class }

  let(:subject) { 'Zendesk Ticket Subject!' }
  let(:description) { 'Zendesk Ticket description' }

  it_behaves_like 'RequiredAttributes' do
    let(:valid_attributes) {{
      subject: subject
    }}
  end

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
end
