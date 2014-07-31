class PlacesController < ApiController
  PUBLIC_ACTIONS << def show
    custom_respond_with Place.find params[:id]
  end

  def suggest
    query = params.fetch(:query)
    lat_lon = params.fetch(:lat_lon)

    service = SuggestFoursquareVenue.call(query: query, lat_lon: lat_lon)
    if service.valid?
      render_json service.response
    else
      render_json_errors service.errors
    end
  end

  PUBLIC_ACTIONS << def users
    custom_respond_with User.joins(:employments)
                            .paginate(pagination_params, User)
                            .where(employments: { place_id: params[:id] })
                            .order(User.arel_table[:id].desc)
                            .select('users.*, employments.title'),
                        each_serializer: SlimFollowedUserSerializer
  end

  private

  authorize_actions_for Place, except: PUBLIC_ACTIONS, actions: { suggest: :create }

  class PlaceParams
    def self.build(params)
      params.require(:place).permit(:id, :foursquare_venue_id, :name, :address, :city, :state)
    end
  end
end
