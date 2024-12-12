# frozen_string_literal: true

module Users
  class SessionsController < Devise::SessionsController
    before_action :configure_sign_in_params, only: [:create]

    # GET /resource/sign_in
    def new
      super do |resource|
        if resource.errors.any?
          flash[:alert] = 'Invalid email or password' # Thông báo lỗi đăng nhập sai
        end
      end
    end

    # POST /resource/sign_in
    def create
      super do |resource|
        if resource.errors.any?
          flash[:alert] = 'Invalid email or password' # Thông báo lỗi đăng nhập sai
        end
      end
    end

    # DELETE /resource/sign_out
    def destroy
      super do |_resource|
        flash[:notice] = 'You have been logged out successfully' # Thông báo đăng xuất thành công
      end
    end

    protected

    # If you have extra params to permit, append them to the sanitizer.
    def configure_sign_in_params
      devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
    end
  end
end
