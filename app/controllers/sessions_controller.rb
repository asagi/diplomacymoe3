class SessionsController < ApplicationController
  def login
    raise CustomError::BadRequest unless  params[:provider]
    raise CustomError::BadRequest unless  params[:callback]

    redirect_to "/auth/#{params[:provider]}?redirect=#{params[:callback]}"
  end

  def create
    user = User.find_or_create_from_auth(request.env['omniauth.auth'])
    render json: user
    #redirect_to request.env['omniauth.params']['callback']
  end

  def failure
    raise CustomError::Unauthorized
    #redirect_to request.env['omniauth.params']['callback']
  end

  def destroy
    reset_session
    render json: {}
  end
end
