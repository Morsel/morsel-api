class ContactController < ApiController
  PUBLIC_ACTIONS << def create
    ContactWorker.perform_async params.slice(:name, :email, :subject, :description)
    render_json_ok
  end
end
