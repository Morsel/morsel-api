class CuisinesController < ApiController
  PUBLIC_ACTIONS = [:index]
  respond_to :json

  def index
    if params[:user_id]
      custom_respond_with Cuisine.includes(:cuisine_users).where(cuisine_users: { user_id: params[:user_id] })
    else
      custom_respond_with Cuisine.all
    end
  end

  def users
    custom_respond_with User.includes(:cuisine_users).where(cuisine_users: { cuisine_id: params[:id] })
  end
end
