class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  module CustomError
    class BadRequest < StandardError; end
    class Unauthorized < StandardError; end
  end

  rescue_from StandardError, with: :render_500

  rescue_from ActiveRecord::RecordInvalid, with: :render_400
  rescue_from ActiveRecord::RecordNotFound, with: :render_404
  rescue_from ActionController::RoutingError, with: :render_404

  rescue_from CustomError::BadRequest, with: :render_400
  rescue_from CustomError::Unauthorized, with: :render_401

  def render_400(e)
    render_error(e, 400)
  end

  def render_401(e)
    render_error(e, 401)
  end

  def render_404
    render_error(e, 404)
  end

  def render_409
    render_error(e, 409)
  end

  def render_500(e)
    render_error(e, 500)
  end

  def render_error(e, status)
    render json: { "error": e }, status: status
  end

  protected

  def authenticate
    authenticate_or_request_with_http_token do |token, options|
      @auth_user = User.find_by(token: token)
    end
  end
end
