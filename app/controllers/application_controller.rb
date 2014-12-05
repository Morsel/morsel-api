class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session
  include PaperTrailable

  before_filter :authenticate_user!

  def authenticate_admin_user!
    redirect_to new_user_session_path unless current_user.try(:admin?)
  end
end
