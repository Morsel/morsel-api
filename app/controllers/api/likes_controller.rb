class Api::LikesController < Api::ApiController
  respond_to :json

  def create
    @morsel = Morsel.find(params[:morsel_id])
    if @morsel.liking_users.include? current_user
      json_response_with_errors(['Already liked'], :bad_request)
    else
      @morsel.liking_users << current_user

      render json: 'OK', status: :ok
    end
  end

  def destroy
    @morsel = Morsel.find(params[:morsel_id])
    if @morsel.liking_users.include? current_user
      @morsel.liking_users.delete(current_user)

      render json: 'OK', status: :ok
    else
      json_response_with_errors(['Not liked'], :not_found)
    end
  end
end