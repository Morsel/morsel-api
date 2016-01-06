class MorselsController < ApiController
  def create
    morsel = Morsel.create(params[:morsel].present? ? MorselParams.build(params) : nil) do |m|
      m.creator = current_user
    end

    if morsel.valid?
      custom_respond_with morsel
    else
      render_json_errors morsel.errors
    end
  end

  public_actions << def index
    if morsels_for_params.nil?
      unauthorized_token
    else
      custom_respond_with_cached_serializer(morsels_for_params,MorselSerializer)
    end
  end

  def drafts
    # HACK: Support for older clients that don't yet support before_/after_date
    if pagination_params.include? :max_id
      custom_respond_with Morsel.includes(:items, :place, :creator)
                                .drafts
                                .paginate(pagination_params, :id)
                                .where(creator_id: current_user.id)
    else
      custom_respond_with Morsel.includes(:items, :place, :creator)
                                .drafts
                                .order(Morsel.arel_table[:updated_at].desc)
                                .paginate(pagination_params, :updated_at)
                                .where(creator_id: current_user.id)
    end
  end

  public_actions << def show
    custom_respond_with Morsel.includes(:items, :place, :creator).find(params[:id])
  end

  def update
    morsel = Morsel.includes(:items, :place, :creator).find params[:id]
    authorize_action_for morsel
    morsel_params = MorselParams.build(params)

    if morsel_params[:schedual_date]
      change_time_zone(morsel_params,morsel)

      morsel.morsel_keywords.present? ? morsel_schedule_update(morsel) : render_json_errors("error")
    else
      morsel_update(morsel)
    end
  end

  def morsel_update(morsel)
    if morsel.update(MorselParams.build(params))
        custom_respond_with morsel
      else
        render_json_errors morsel.errors
      end
  end

   def morsel_schedule_update(morsel)

    if morsel.save
        custom_respond_with morsel
      else
        render_json_errors morsel.errors
      end
  end

  def delete_morsel_keyword
    morsel = Morsel.find params[:morsel_id]
    ids = MorselParams.build(params)[:morsel_keyword_ids]
    keyword_to_delete = morsel.morsel_morsel_keywords.find_by_morsel_keyword_id(ids)
    if keyword_to_delete.delete
      render_json "deleted"
    else
      render_json_errors morsel.errors
    end
  end

  public_actions << def update_morsel_keyword
    morsel = Morsel.find params[:morsel_id]
    user = User.find params[:user_id]
    if morsel.update(MorselParams.build(params, user)) && (morsel.feed_item ? morsel.feed_item.save : true)

       render_json_ok

    else
        render_json_errors({ api: ["Invalid Parameter To call."] }, :forbidden)
    end

  end

   public_actions << def update_morsel_topic
    morsel = Morsel.find params[:morsel_id]
    user = User.find params[:user_id]
    if morsel.update(MorselParams.build(params, user)) && (morsel.feed_item ? morsel.feed_item.save : true)
       render_json_ok
    else
        render_json_errors({ api: ["Invalid Parameter To call."] }, :forbidden)
    end
  end

  public_actions << def associate_morsel_to_user
    morsel = Morsel.find params[:morsel_id]
    #user = User.find params[:user_id]
    #morsel.associated_morsels.find_or_create_by(:user=>user)
    if morsel.update(MorselParams.build(params)) && morsel.associated_morsels.update_all(:user_id => morsel.user_id)
       render_json_ok
    else
        render_json_errors({ api: ["Invalid Parameter To call."] }, :forbidden)
    end
  end


  public_actions << def check_publish

    user= User.find(params[:userId]) if params[:userId]
    profile = user.profile
    associated_user = user.recieved_association_requests.approved

    if profile.present? || associated_user.present?
      render_json 'OK'
    else
      render_json 'NO'
    end
  end

  public_actions << def check_then_publish
    user_profile = User.find(params[:userId]).profile
    morsel_keyword = Morsel.find(params[:id]).morsel_morsel_keywords.pluck(:morsel_keyword_id)
    if user_profile.present? && morsel_keyword.present?
      morsel = Morsel.includes(:items, :place, :creator).find params[:id]
      authorize_action_for morsel
      #morsel.update! draft: false, publishing: false, is_submit: false
      NewsletterWorker.new.perform(morsel:morsel)
      custom_respond_with_service publish_service(morsel)
    else
       render_json 'NOT'
    end
  end


  def destroy
    morsel = Morsel.find(params[:id])
    authorize_action_for morsel

    if morsel.destroy
      render_json_ok
    else
      render_json_errors(morsel.errors)
    end
  end

  def publish

    morsel = Morsel.includes(:items, :place, :creator).find params[:id]
    authorize_action_for morsel

    custom_respond_with_service publish_service(morsel)
  end

  def republish
    morsel = Morsel.includes(:items, :place, :creator).find params[:id]
    authorize_action_for morsel

    custom_respond_with_service publish_service(morsel, true)
  end

  def collect
    morsel = Morsel.find params.fetch(:id)
    authorize_action_for morsel

    service = CollectMorsel.call(
      morsel: morsel,
      collection: Collection.find(params.fetch(:collection_id)),
      user: current_user,
      note: params[:note]
    )

    custom_respond_with_service service, serializer: SlimMorselWithNoteSerializer
  end

  def uncollect
    morsel = Morsel.find params.fetch(:id)
    authorize_action_for morsel

    service = UncollectMorsel.call(
      morsel: morsel,
      collection: Collection.find(params.fetch(:collection_id)),
      user: current_user
    )

    render_json_with_service service, serializer: SlimMorselWithNoteSerializer
  end

  public_actions << def search
    if params[:morsel].present?
      morsel_params = MorselParams.build(params)
      query = morsel_params.fetch(:query)
      queue_user_event(:morsel_search, nil, { query: query })
      custom_respond_with Morsel.includes(:place, :creator)
                                .published
                                .full_search(query)
                                .page_paginate(pagination_params)
                                .order(Morsel.arel_table[:published_at].desc),
                          each_serializer: SlimMorselSerializer
    else
      custom_respond_with Morsel.includes(:place, :creator)
                                .published
                                .page_paginate(pagination_params)
                                .order(Morsel.arel_table[:published_at].desc),
                          each_serializer: SlimMorselSerializer
    end
  end

  class MorselParams
    def self.build(params, _scope = nil)

      if _scope && _scope.admin?
        params.require(:morsel).permit(:title, :summary, :schedual_date,:local_schedual_date, :draft, :primary_item_id, :place_id, :template_id, :query, :user_id,:morsel_video,:video_text, feed_item_attributes: [:id, :featured],morsel_keyword_ids: [],morsel_topic_ids: [],morsel_host_ids: [])
      else
        params.require(:morsel).permit(:title, :summary, :schedual_date,:local_schedual_date, :draft, :primary_item_id, :place_id, :template_id, :query, :user_id, :is_submit,:morsel_video,:video_text,morsel_keyword_ids: [],morsel_topic_ids: [],morsel_host_ids:[])
      end
    end
  end

  private
  def change_time_zone(morsel_params,morsel)

    if morsel_params[:schedual_date].present?
        morsel.local_schedual_date = morsel_params[:schedual_date]
        morsel.save
        morsel.schedual_date = morsel.updated_at
      # time = Time.parse(morsel_params[:schedual_date])
      # morsel.schedual_date = time.in_time_zone("Europe/London").strftime("%Y-%m-%d %H:%M:00")
    end
  end
  def morsels_for_params

    @morsels_for_params ||= begin
      # HACK: Support for older clients that don't yet support before_/after_date
      if pagination_params.include? :max_id
        pagination_key = :id
      else
        pagination_key = :published_at
      end

      if params[:place_id] || params[:user_id] || params[:username]
        user_id = params[:user_id] || if params[:place_id].nil?
                                          user = User.find_by_id_or_username params[:username]
                                          raise ActiveRecord::RecordNotFound if user.nil?
                                          user.id
                                      end
        host = User.find(user_id)
        fetch_morsels = Morsel.get_associated_users_morsels(host.id, pagination_params, pagination_key)
        if params[:topic_id]
          fetch_morsels.published.where_topic_id(params[:topic_id])
        elsif params[:keyword_id]
          fetch_morsels.published.where_keyword_id(params[:keyword_id])
        elsif params[:submit]
          fetch_morsels.submitted
        else
          fetch_morsels.published.where_place_id(params[:place_id])
        end

      elsif current_user.present?
        Morsel.includes(:items, :place, :creator)
              .with_drafts(true)
              .order(Morsel.arel_table[:updated_at].desc)
              .paginate(pagination_params, :updated_at)
              .where_creator_id(current_user.id)
      end
    end
  end

  def publish_service(morsel, should_republish = false)
    PublishMorsel.call(
      morsel: morsel,
      morsel_params: (params[:morsel].present? ? MorselParams.build(params) : nil),
      social_params: {
        post_to_facebook: params[:post_to_facebook],
        post_to_twitter: params[:post_to_twitter]
      },
      should_republish: should_republish
    )
  end

  authorize_actions_for Morsel, except: public_actions, actions: { delete_morsel_keyword: :delete ,publish: :update, republish: :update, drafts: :read, collect: :read, uncollect: :read, check_then_publish: :update }
end
