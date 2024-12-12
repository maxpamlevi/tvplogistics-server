class Api::V1::SessionsController < Devise::SessionsController
  skip_before_action :verify_authenticity_token
  before_action :ensure_params_exist, only: [:create]

  respond_to :json

  def create
    user = User.find_by(email: params[:user][:email])

    if user && user.valid_password?(params[:user][:password])
      token = JwtService.encode(user_id: user.id, role: user.role, name: user.name)
      render json: { authToken: token, user: { name: user.name, email: user.email, role: user.role } }, status: :ok
    else
      render json: { message: 'Invalid email or password' }, status: :unauthorized
    end
  end

  def destroy
    sign_out(current_user) # Log out the user via Devise
    cookies.delete(:user_id) # Remove the cookie
    render json: { message: "Logged out successfully" }, status: :ok
  end

  private

  def ensure_params_exist
    return unless params[:user][:email].blank? || params[:user][:password].blank?
    render json: { message: 'Missing email or password' }, status: :bad_request
  end

  def respond_with(resource, _opts = {})
    Rails.logger.info("#{resource.inspect}")

    if resource.persisted?
      render json: { message: 'Logged in successfully.', user: current_user }, status: :ok
    else
      render json: { message: 'Invalid login credentials' }, status: :unauthorized
    end
  end

  def respond_to_on_destroy
    render json: { message: 'Logged out successfully' }, status: :ok
  end
end
