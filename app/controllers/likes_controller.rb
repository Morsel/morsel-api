class LikesController < ApiController
  respond_to :json

  def create
    @morsel = Morsel.find(params[:morsel_id])
    if @morsel.likers.include? current_user
      render_json_errors({ like: ['already exist'] }, :bad_request)
    else
      @morsel.likers << current_user

      render json: 'OK', status: :ok
    end
  end

  def destroy
    @morsel = Morsel.find(params[:morsel_id])
    if @morsel.likers.include? current_user
      @morsel.likers.delete(current_user)

      render json: 'OK', status: :ok
    else
      render_json_errors({ like: ['not found'] }, :not_found)
    end
  end
end
