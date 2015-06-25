class ContactWorker
  include Sidekiq::Worker

  def perform(options = nil)  	
    return if options.nil?    
    UserMailer.send_contact_email_to_user(options[:name],options[:email],options[:subject],options[:description]).deliver
    UserMailer.send_contact_email_to_admin(options[:name],options[:email],options[:subject],options[:description]).deliver
    # Zendesk Ticket system 
    #CreateZendeskTicket.call(options.symbolize_keys.merge(tags: ['contact-form', 'api', Rails.env]))
  end
end
