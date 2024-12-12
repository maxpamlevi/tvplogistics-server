# frozen_string_literal: true

module Users
  class RegistrationsController < Devise::RegistrationsController
    # skip_before_action :verify_authenticity_token
    #
    # before_action :authenticate_user!, only: [:new, :create]
    before_action :check_admin, only: %i[new create]

    before_action :configure_permitted_parameters, if: :devise_controller?

    skip_before_action :require_no_authentication, only: %i[new create]
    # before_action :authenticate_admin!, only: [:new, :create]

    before_action :configure_sign_up_params, only: [:create]
    before_action :configure_account_update_params, only: [:update]

    # GET /resource/sign_up

    # POST /resource

    # GET /resource/edit

    # PUT /resource

    # DELETE /resource

    # GET /resource/cancel
    # Forces the session data which is usually expired after sign
    # in to be expired now. This is useful if the user wants to
    # cancel oauth signing in/up in the middle of the process,
    # removing all OAuth session data.

    private

    def check_admin
      return if user_signed_in? && current_user.admin?

      redirect_to root_path
      flash[:notice] = 'Only admins can create new accounts.'
    end

    def authenticate_admin!
      return if user_signed_in? && current_user.admin?

      redirect_to root_path
      flash[:notice] = 'Only admins can create new accounts.'
    end

    protected

    # If you have extra params to permit, append them to the sanitizer.
    def configure_sign_up_params
      devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
    end

    # If you have extra params to permit, append them to the sanitizer.
    def configure_account_update_params
      devise_parameter_sanitizer.permit(:account_update, keys: %i[attribute user_no phone name])
    end

    # The path used after sign up.

    # The path used after sign up for inactive accounts.

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up, keys: %i[name phone user_no])
    end
  end
end
