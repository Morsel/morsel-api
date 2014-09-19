class TagsController < ApiController
  PUBLIC_ACTIONS << def cuisines
    custom_respond_with Tag.joins(:keyword)
                           .where(keywords: { type: 'Cuisine' }, tags: { taggable_type: taggable_type, taggable_id: params[:id] })
                           .order(Tag.arel_table[:id].asc)
  end

  PUBLIC_ACTIONS << def specialties
    custom_respond_with Tag.joins(:keyword)
                           .where(keywords: { type: 'Specialty' }, tags: { taggable_type: taggable_type, taggable_id: params[:id] })
                           .order(Tag.arel_table[:id].asc)
  end

  def create
    tag_params = TagParams.build(params)

    if Tag.find_by(taggable_id: params[:id], taggable_type: taggable_type, tagger_id: current_user.id, keyword_id: tag_params.fetch(:keyword_id))
      render_json_errors("#{taggable_type.underscore}" => ['already tagged with that keyword'])
    else
      tag = Tag.new(taggable_id: params[:id], taggable_type: taggable_type, tagger_id: current_user.id, keyword_id: tag_params.fetch(:keyword_id))

      if tag.save
        custom_respond_with tag
      else
        render_json_errors tag.errors
      end
    end
  end

  def destroy
    tag = Tag.find_by(id: params[:tag_id])
    record_not_found && return unless tag
    authorize_action_for tag

    if tag.destroy
      render_json_ok
    else
      render_json_errors tag.errors
    end
  end

  private

  authorize_actions_for Tag, except: PUBLIC_ACTIONS

  def taggable_type
    request.path.split('/').second.classify
  end

  class TagParams
    def self.build(params, _scope = nil)
      params.require(:tag).permit(:keyword_id)
    end
  end
end
