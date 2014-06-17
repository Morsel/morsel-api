class EmploymentsController < ApiController
  def create
    title = params.fetch(:title)

    if params[:place_id].present?
      place = Place.find params[:place_id]
    else
      foursquare_venue_id = params[:foursquare_venue_id] || params[:place][:foursquare_venue_id]
      if foursquare_venue_id.present?
        place = Place.find_or_create_by(foursquare_venue_id: foursquare_venue_id) do |p|
          p.attributes = PlacesController::PlaceParams.build(params) if params[:place]
          p.creator_id = current_user.id
        end

        render_json_errors(place.errors) && return unless place.valid?
      end
    end

    if place.employ(current_user, title)
      custom_respond_with place,  serializer: SlimPlaceWithTitleSerializer,
                                  context: { title: title }
    else
      render_json_errors place.errors
    end
  end

  def destroy
    employment = Employment.find_by(place_id: params[:place_id], user_id: current_user.id)

    render_json_errors('place' => ['not joined']) && return unless employment
    authorize_action_for employment

    if employment.destroy
      render_json 'OK'
    else
      render_json_errors employment.errors
    end
  end

  private

  authorize_actions_for Employment, except: PUBLIC_ACTIONS, actions: { users: :read }
end
