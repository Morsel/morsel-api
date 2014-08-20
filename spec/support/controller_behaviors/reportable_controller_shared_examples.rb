shared_examples 'ReportableController' do
  describe 'POST /reportable/:id/report' do
    let(:endpoint) { "#{reportable_route}/#{reportable.id}/report" }

    it 'reports the Reportable' do
      stub_zendesk_settings
      stub_zendesk_client

      CreateZendeskTicket.any_instance.should_receive(:call).exactly(1).times.and_call_original

      Sidekiq::Testing.inline! do
        post_endpoint
      end

      expect_success
    end
  end
end
