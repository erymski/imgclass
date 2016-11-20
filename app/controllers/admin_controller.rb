class AdminController < ApplicationController
    before_filter :ensure_admin
    before_action :set_user, only: [:destroy, :to_admin, :to_user]
    before_action :avoid_current_user, only: [:destroy, :to_admin, :to_user]

    def dashboard
    end

    def admins
        @admins = User.where(:is_admin => true)
    end

    def users
        @users = User.where(:is_admin => false)
    end

    def to_admin

        @user.is_admin = true
        @user.save

        respond_to do |format|
            format.html { redirect_to action: "all", notice: 'Role changed to admin.' }
            format.json { head :no_content }
        end        
    end

    def to_user

        @user.is_admin = false
        @user.save

        respond_to do |format|
            format.html { redirect_to action: "all", notice: 'Role changed to user.' }
            format.json { head :no_content }
        end        
    end

    # DELETE /admin/1
    def destroy

        @user.destroy

        respond_to do |format|
            format.html { redirect_to action: "all", notice: 'User was successfully deleted.' }
            format.json { head :no_content }
        end        
    end

private
    # only admins allowed to use this page
    def ensure_admin
        if ! user_signed_in? || ! current_user.is_admin
            render file: "#{Rails.root}/public/404.html", layout: false, status: 404
        end
    end

    # don't perform action on current user
    def avoid_current_user

        if current_user.id == @user.id
            respond_to do |format|
                format.html { redirect_to action: "all", notice: 'Cannot perform action on active user.' }
                format.json { head :no_content }
            end        
        end
    end

    # load user by id
    def set_user
      @user = User.find(params[:id])
    end
end