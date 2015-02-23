class ContactController < ApiController
  public_actions << def create  	
    ContactWorker.perform_async params.slice(:name, :email, :subject, :description)
    #ContactWorker.perform_in('2015-02-23 07:45:53',params.slice(:name, :email, :subject, :description))
    render_json_ok
  end
end
