module PaperTrailable
  extend ActiveSupport::Concern

  def user_for_paper_trail
    'Unknown'
    # user_signed_in? ? current_user.id : 'Unknown'
  end
end
