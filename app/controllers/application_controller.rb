class ApplicationController < ActionController::Base
  before_filter :authenticate_user!

  #helper_method :anything
  helper_method :current_user_or_guest

  def current_user_or_guest
    if user_signed_in?
      current_user
    else
      @guest_user ||= User.anonymous
    end
  end

  

end
