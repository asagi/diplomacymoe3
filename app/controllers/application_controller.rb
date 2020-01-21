# frozen_string_literal: true

class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  module CustomError
    class BadRequest < StandardError; end
    class Unauthorized < StandardError; end
    class Forbidden < StandardError; end
    class Conflict < StandardError; end
  end

  rescue_from StandardError, with: :render_500

  rescue_from ActiveRecord::RecordInvalid, with: :render_400
  rescue_from ActiveRecord::RecordNotFound, with: :render_404
  rescue_from ActionController::RoutingError, with: :render_404

  rescue_from CustomError::BadRequest, with: :render_400
  rescue_from CustomError::Unauthorized, with: :render_401
  rescue_from CustomError::Forbidden, with: :render_403
  rescue_from CustomError::Conflict, with: :render_409

  def render_400(e)
    render_error(e, 400)
  end

  def render_401(e)
    render_error(e, 401)
  end

  def render_403(e)
    render_error(e, 403)
  end

  def render_404(e)
    render_error(e, 404)
  end

  def render_409(e)
    render_error(e, 409)
  end

  def render_500(e)
    render_error(e, 500)
  end

  def render_error(e, status)
    render json: { errors: JSON.parse(e.message) }, status: status
  end

  protected

  def authenticate
    raise CustomError::Forbidden unless authenticate_user
  end

  def authenticate_user
    authenticate_with_http_token do |token, _options|
      @auth_user = User.find_by(token: token)
    end
  end
end
