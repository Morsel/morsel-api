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

  public_actions << def add_keyword
  
    if MorselKeywordParams.build(params).present?
        morselkeyword = MorselKeyword.create(name: params[:keyword][:name],user_id: params[:keyword][:user_id]);
        
          if morselkeyword.present?
            render_json morselkeyword
          end 
    else
        render_json_errors({ api: ["Invalid Parameter To call."] }, :forbidden) 
    end

  end

  public_actions << def show_morsel_keyword
    
    if MorselKeywordParams.build(params).present?
        all_morsel_keyword = User.find(params[:keyword][:user_id]).morsel_keywords
          if all_morsel_keyword.present?
            render_json all_morsel_keyword
          else
            render_json "blank"
          end 

    else
        render_json_errors({ api: ["Invalid Parameter To call."] }, :forbidden) 
    end
  
  end

  public_actions << def edit_morsel_keyword
   
    if MorselKeywordParams.build(params).present?
      morsel_keyword = MorselKeyword.find(params[:keyword][:id])
        if morsel_keyword.update(name: params[:keyword][:name])
            render_json_ok
        end 
    else
        render_json_errors({ api: ["Invalid Parameter To call."] }, :forbidden) 
    end
  
  end

   public_actions << def selected_morsel_keyword
    
    if MorselKeywordParams.build(params).present?
      selected_morsel_keyword = Morsel.find(params[:keyword][:morsel_id]).morsel_morsel_keywords.pluck(:morsel_keyword_id)
      
         if selected_morsel_keyword.present?
             render_json selected_morsel_keyword
         else
              show_morsel_keyword
         end 
    else
        render_json_errors({ api: ["Invalid Parameter To call."] }, :forbidden) 
    end
  
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

  class MorselKeywordParams
    def self.build(params, _scope = nil)
      params.require(:keyword).permit(:name,:user_id,:id,:morsel_id)
    end
  end

  authorize_actions_for Keyword, except: public_actions, actions: { users: :read, morsels_for_name: :read, search: :read, add_keyword: :read, show_morsel_keyword: :read }
end
