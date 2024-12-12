module Api
  class BaseController < ActionController::API
    attr_reader :current_user, :branch

    before_action :authenticate_request, :handle_cookies_branch
    private

    def authenticate_request
      header = request.headers['Authorization']
      token = header&.split(' ')&.last
      decoded = JwtService.decode(token)

      if decoded.nil? || Time.current > Time.at(decoded[:exp])
        raise UnauthorizedError, 'Unauthorized'
      end

      @current_user = User.find_by(id: decoded[:user_id])
      raise UnauthorizedError, 'Unauthorized' if @current_user.blank?
    end

    def handle_cookies_branch
      @branch = request.headers['Branch'] || 'tvpl'
    end
  end
end
