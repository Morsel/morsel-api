class LikesController < ApiController
  respond_to :json

  def create
    morsel = Morsel.find(params[:morsel_id])
    if morsel.likers.include? current_user
      render_json_errors({ like: ['already exist'] }, :bad_request)
    elsif morsel.likers << current_user
      render json: 'OK', status: :ok
    else
      render_json_errors(morsel.errors, :unprocessable_entity)
    end
  end

  def destroy
    morsel = Morsel.find(params[:morsel_id])
    if morsel.likers.include? current_user
      if morsel.likers.destroy(current_user)
        render json: 'OK', status: :ok
      else
        render_json_errors(morsel.errors, :unprocessable_entity)
      end

    else
      render_json_errors({ like: ['not found'] }, :not_found)
    end
  end
end
