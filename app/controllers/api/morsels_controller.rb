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

      @post.title = params[:post_title] if params[:post_title].present?

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
    if params[:post_id].present?
      # Appending a Morsel to a Post
      post = Post.find(params[:post_id])
      if post.morsels.include? @morsel
        # Already exists
        json_response_with_errors(['Relationship already exists'], :bad_request)
      else
        post.morsels << @morsel
      end
    else
      # Updating a Morsel
      @morsel.update_attributes(MorselParams.build(params))
    end
  end

  def destroy
    morsel = Morsel.find(params[:id])
    if params[:post_id].present?
      # Removing a Morsel from a Post
      post = Post.find(params[:post_id])
      if post.morsels.include? morsel
        post.morsels.delete(morsel)

        render json: 'OK', status: :ok
      else
        json_response_with_errors(['Relationship not found'], :not_found)
      end
    else
      # Deleting a Morsel
      morsel.destroy
      render json: 'OK', status: :ok
    end
  end

  class MorselParams
    def self.build(params)
      params.require(:morsel).permit(:description, :photo)
    end
  end
end
