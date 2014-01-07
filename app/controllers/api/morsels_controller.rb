class Api::MorselsController < Api::ApiController
  respond_to :json

  def index
    if params[:user_id].blank?
      @morsels = Morsel.all
    else
      @morsels = Morsel.find_all_by_creator_id params[:user_id]
    end
  end

  def create
    morsel_params = MorselParams.build(params)

    @morsel = current_user.morsels.build(morsel_params)

    if @morsel.save
      if params[:post_id].present?
        @post = Post.find(params[:post_id])
      else
        # If a post is not specified for this Morsel, create a new one
        @post = Post.new
        @post.creator = current_user
      end

      @post.morsels.push(@morsel)
      @post.save!
    else
      json_response_with_errors(@morsel.errors.full_messages, :unprocessable_entity)
    end
  end

  def show
    @morsel = Morsel.find(params[:id])
  end

  def update
    @morsel = Morsel.find(params[:id])
    @morsel.update_attributes(MorselParams.build(params))
  end

  class MorselParams
    def self.build(params)
      params.require(:morsel).permit(:description, :photo)
    end
  end
end
