# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :handle_cookies_branch

  def authenticate_admin!
    return if user_signed_in? && current_user.admin?

    flash[:notice] = "You don't have permission !"
  end

  def handle_cookies_branch
    @branch = cookies[:branch]
  end

  # def after_sign_in_path_for(resource)
  #   dashboard_path
  # end
end
