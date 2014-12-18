class KeywordsController < ApiController
  public_actions << def cuisines
    custom_respond_with Keyword.where(type: 'Cuisine'), each_serializer: KeywordSerializer
  end

  public_actions << def specialties
    custom_respond_with Keyword.where(type: 'Specialty'), each_serializer: KeywordSerializer
  end

  public_actions << def morsels_for_name
    custom_respond_with Morsel.joins(:keywords)
                              .page_paginate(pagination_params)
                              .where(Hashtag.arel_table[:name].lower.eq(params.fetch(:name).downcase))
                              .order(Tag.arel_table[:id].desc),
                        each_serializer: SlimMorselSerializer
  end

  public_actions << def users
    custom_respond_with User.joins(:tags)
                            .paginate(pagination_params)
                            .where(tags: { keyword_id: params[:id] })
                            .order(Tag.arel_table[:id].desc)
  end

  public_actions << def search
    service = Search::SearchKeywords.call(KeywordParams.build(params).merge(pagination_params).merge(type: keyword_type))
    custom_respond_with_service service, each_serializer: KeywordSerializer
  end

  private

  def keyword_type
    request.path.split('/').second.classify
  end

  class KeywordParams
    def self.build(params, _scope = nil)
      params.require(:keyword).permit(:name, :type, :promoted, :query)
    end
  end

  authorize_actions_for Keyword, except: public_actions, actions: { users: :read, morsels_for_name: :read, search: :read }
end
