class StaticController < ApplicationController

  def index
    if user_signed_in? then
      if current_user.is_admin then
        redirect_to url_for(:controller => 'admin', :action => 'dashboard')
      else
        redirect_to url_for(:controller => 'jobs', :action => 'index')
      end
    end 
  end
  
end
