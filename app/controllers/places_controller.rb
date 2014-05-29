class PlacesController < ApiController
  PUBLIC_ACTIONS << def show
    custom_respond_with Place.find params[:id]
  end

  def join
    title = params.fetch(:title)
    place_params = PlaceParams.build(params)

    if place_params[:id].present?
      place = Place.find place_params[:id]
    elsif place_params[:foursquare_venue_id].present?
      place = Place.find_or_create_by(foursquare_venue_id: place_params[:foursquare_venue_id]) do |p|
        p.attributes = place_params
        p.creator_id = current_user.id
      end

      render_json_errors(place.errors) && return unless place.valid?
    end

    if place.employ(current_user, title)
      custom_respond_with place,  serializer: SlimPlaceWithTitleSerializer,
                                  context: { title: title }
    else
      render_json_errors place.errors
    end
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
                            .since(params[:since_id], 'employments')
                            .max(params[:max_id], 'employments')
                            .where(employments: { place_id: params[:id] })
                            .limit(pagination_count)
                            .order('employments.id DESC')
                            .select('users.*, employments.title'),
                        each_serializer: SlimFollowedUserSerializer
  end

  private

  authorize_actions_for Place, except: PUBLIC_ACTIONS, actions: { join: :create, suggest: :read }

  class PlaceParams
    def self.build(params)
      params.require(:place).permit(:id, :foursquare_venue_id, :name, :address, :city, :state)
    end
  end
end
