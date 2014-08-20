shared_examples 'ReportableController' do
  describe 'POST /reportable/:id/report' do
    let(:endpoint) { "#{reportable_route}/#{reportable.id}/report" }

    it 'reports the Reportable' do
      stub_zendesk_settings
      stub_zendesk_client

      params = {
        name: current_user.username,
        subject: "[AUTOMATED] #{reportable.class} ##{reportable.id} reported!",
        description: "#{current_user.username} (#{current_user.url}) has reported #{reportable.url}",
        tags: ['reported', 'api', 'test'],
        type: 'incident'
      }

      CreateZendeskTicket.should_receive(:call).with(hash_including(params)).exactly(1).times.and_call_original

      Sidekiq::Testing.inline! do
        post_endpoint
      end

      expect_success
    end
  end
end
