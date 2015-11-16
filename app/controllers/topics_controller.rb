class TopicsController < ApiController

  public_actions << def add_topic

    if MorselTopicParams.build(params).present?
        morseltopic = MorselTopic.create(name: params[:topic][:name],user_id: params[:topic][:user_id]);

          if morseltopic.present?
            render_json morseltopic
          end
    else
        render_json_errors({ api: ["Invalid Parameter To call."] }, :forbidden)
    end

  end

  public_actions << def show_morsel_topic

    if MorselTopicParams.build(params).present?
        all_morsel_topic = User.find(params[:topic][:user_id]).morsel_topics
          if all_morsel_topic.present?
            render_json all_morsel_topic
          else
            render_json "blank"
          end

    else
        render_json_errors({ api: ["Invalid Parameter To call."] }, :forbidden)
    end

  end

  public_actions << def edit_morsel_topic

    if MorselTopicParams.build(params).present?
      morsel_topic = MorselTopic.find(params[:topic][:id])
        if morsel_topic.update(name: params[:topic][:name])
            render_json_ok
        end
    else
        render_json_errors({ api: ["Invalid Parameter To call."] }, :forbidden)
    end

  end

   public_actions << def selected_morsel_topic

    if MorselTopicParams.build(params).present?
      selected_morsel_topic = Morsel.find(params[:topic][:morsel_id]).morsel_morsel_topics.pluck(:morsel_topic_id)

         if selected_morsel_topic.present?
             render_json selected_morsel_topic
         else
              show_morsel_topic
         end
    else
        render_json_errors({ api: ["Invalid Parameter To call."] }, :forbidden)
    end

  end

   public_actions << def delete_morsel_topic

    if MorselTopicParams.build(params).present?
      morsel_topic = MorselTopic.find(params[:topic][:id])
        if morsel_topic.destroy()
            render_json_ok
        end
    else
        render_json_errors({ api: ["Invalid Parameter To call."] }, :forbidden)
    end

  end

  private

   class MorselTopicParams
    def self.build(params, _scope = nil)
      params.require(:topic).permit(:name,:user_id,:id,:morsel_id)
    end
  end

  authorize_actions_for MorselTopic, except: public_actions, actions: {  add_topic: :read, show_morsel_topic: :read }

end
