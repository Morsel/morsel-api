class Api::MorselsController < Api::ApiController
  respond_to :json

  def index
    respond_with Morsel.all
  end

  def create
    morsel_params = MorselParams.build(params)

    # TODO: Assert that either description or image exist

    morsel = current_user.morsels.build(morsel_params)

    morsel.save!

    respond_with morsel, location: root_path
  end

  def show
    respond_with Morsel.find(params[:id])
  end

  def update
  end

  class MorselParams
    def self.build(params)
      params.permit(:description)
    end
  end
end
