class NewsletterService
  include Service
  attribute :morsel, Morsel
  attribute :template, String

  TO = "ellen@eatmorsel.com"
  FROM = "nishant.n@cisinlabs.com"


  def call
  	subscribers = Subscription.where(creator_id:morsel.creator_id)  #Subscription.all
  	uniq_subscribers = subscribers.group_by {|art| art.user}.keys
    morsel_keyword_ids = morsel.morsel_keywords.map(&:id)

  	view = ActionView::Base.new('app/views/', {}, ActionController::Base.new)
    latest_morsel = Morsel.where(creator_id: morsel.creator_id).where.not(id: morsel.id).order("created_at DESC").limit(3).published

    other_morsel = []

    latest_morsel.each do |latest|

        latest_keyword =  MorselKeyword.joins(:morsels).where(morsels:{id:latest.id}).group('morsel_keywords.id').map(&:id).sort()

         other_morsel.push(latest) if(!latest_keyword.include?(morsel_keyword_ids.sort()) & morsel_keyword_ids.any?)
    end

  	uniq_subscribers.each do |user|
      subscribe_morsel_keyword_ids = Subscription.where(user_id:user.id).map(&:keyword_id).sort()
       email_per_day =  user.email_logs.email_per_day
       if email_per_day.zero?
          sendemail(view,other_morsel,user) if (subscribe_morsel_keyword_ids & morsel_keyword_ids).present?
       end
  	end
  end



  def sendemail (view,other_morsel,user)
		html = view.render(partial: 'user_mailer/morsel_newsletter',locals:{morsel:morsel,other_morsel:other_morsel,description: morsel_item_description(morsel)}).html_safe
		from = ""
		from = " from " if morsel.user.profile.present?
	  message= {"auto_text"=>false,
	  				"preserve_recipients"=>nil,
	  				"html"=>html,
	  				"to"=>[{"type"=>"to","email"=> TO ,"name"=>"Nishant"}],
	  				"return_path_domain"=>nil,
	  				"from_name"=> morsel.user.full_name,"from_email"=> FROM ,
	  				"subject"=>"#{morsel.title} From #{morsel.user.full_name} ",
	  				"headers"=>{"Reply-To"=>"message.reply@example.com"},
	  				"auto_html"=>nil,"important"=>false}
		 begin
       mandrill = MaindrillConnector.new.get_client
		   mandrill.messages.send message

       user.emaillogged_morsel_ids = [morsel.id] | user.emaillogged_morsel_ids.flatten

		 rescue Exception => e
  		puts "********************Error log #{e}"
  	 end
  end

  def morsel_item_description(morsel)
    unless morsel.items && morsel.items.blank?
      description = morsel.items.first.description if morsel.items.first.present?
      ActionView::Base.full_sanitizer.sanitize(description) if !description.nil?
    end
  end

end
