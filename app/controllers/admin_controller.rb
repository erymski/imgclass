class AdminController < ApplicationController
    before_filter :ensure_admin
    before_action :set_user, only: [:destroy]

    def all
        @users = User.all
    end

    def destroy
        
        if current_user.id != @user.id
            @user.destroy
            notice = 'User was successfully deleted.'
        else
            notice = 'Cannot delete active user.'
        end

        respond_to do |format|
            format.html { redirect_to action: "all", notice: notice }
            format.json { head :no_content }
        end        
    end

private
    def ensure_admin
        if ! user_signed_in? || ! current_user.is_admin
            render file: "#{Rails.root}/public/404.html", layout: false, status: 404
        end
    end

    def set_user
      @user = User.find(params[:id])
    end
end