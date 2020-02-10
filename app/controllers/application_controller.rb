# frozen_string_literal: true

class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  module CustomError
    class BadRequest < StandardError; end
    class Unauthorized < StandardError; end
    class Forbidden < StandardError; end
    class Conflict < StandardError; end
    class UnprocessableEntity < StandardError; end
  end

  rescue_from StandardError, with: :render_500

  rescue_from ActiveRecord::RecordInvalid, with: :render_400
  rescue_from ActiveRecord::RecordNotFound, with: :render_404
  rescue_from ActionController::RoutingError, with: :render_404

  rescue_from CustomError::BadRequest, with: :render_400
  rescue_from CustomError::Unauthorized, with: :render_401
  rescue_from CustomError::Forbidden, with: :render_403
  rescue_from CustomError::Conflict, with: :render_409
  rescue_from CustomError::UnprocessableEntity, with: :render_422

  def render_400(error)
    render_error(error, 400)
  end

  def render_401(error)
    render_error(error, 401)
  end

  def render_403(error)
    render_error(error, 403)
  end

  def render_404(error)
    render_error(error, 404)
  end

  def render_409(error)
    render_error(error, 409)
  end

  def render_422(error)
    render_error(error, 422)
  end

  def render_500(error)
    render_error(error, 500)
  end

  def render_error(error, status)
    message = error_to_object(error)
    render json: { errors: message }, status: status
  end

  protected

  def error_to_object(error)
    JSON.parse(error.message)
  rescue StandardError
    error.message
  end

  def authenticate
    raise CustomError::Forbidden unless authenticate_user
  end

  def authenticate_user
    authenticate_with_http_token do |token, _options|
      @auth_user = User.find_by(token: token)
    end
  end
end
