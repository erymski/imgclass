class StaticController < ApplicationController

  def index
    if user_signed_in? then
      if current_user.is_admin then
        redirect_to url_for(:controller => 'admin', :action => 'all')
      else
        redirect_to url_for(:controller => 'image_label_sets', :action => 'index')
      end
    end 
  end
  
end
