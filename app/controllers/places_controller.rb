class PlacesController < ApiController
  public_actions << def show
    custom_respond_with Place.find params[:id]
  end

  def suggest
    query = params.fetch(:query)

    service = SuggestFoursquareVenue.call(query: query, lat_lon: params[:lat_lon], near: params[:near])
    render_json_with_service service
  end

  public_actions << def users
    custom_respond_with User.joins(:employments)
                            .paginate(pagination_params)
                            .where(employments: { place_id: params[:id] })
                            .order(User.arel_table[:id].desc)
                            .select('users.*, employments.title'),
                        each_serializer: SlimFollowedUserSerializer
  end

  private

  authorize_actions_for Place, except: public_actions, actions: { suggest: :create }

  class PlaceParams
    def self.build(params, _scope = nil)
      params.require(:place).permit(:id, :foursquare_venue_id, :name, :address, :city, :state)
    end
  end
end
