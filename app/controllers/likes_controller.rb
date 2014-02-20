class LikesController < ApiController
  respond_to :json

  def create
    create_like = CreateLike.run(
      morsel: Morsel.find(params[:morsel_id]),
      user: current_user
    )

    if create_like.valid?
      render json: 'OK', status: :ok
    else
      render_json_errors(create_like.errors)
    end
  end

  def destroy
    destroy_like = DestroyLike.run(
      morsel: Morsel.find(params[:morsel_id]),
      user: current_user
    )

    if destroy_like.valid?
      render json: 'OK', status: :ok
    else
      render_json_errors(destroy_like.errors)
    end
  end
end
