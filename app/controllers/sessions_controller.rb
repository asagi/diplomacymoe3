class SessionsController < ApplicationController
  before_action :authenticate, only: [ :destroy ]

  def login
    raise CustomError::BadRequest unless  params[:provider]
    raise CustomError::BadRequest unless  params[:callback]
    redirect_to "/auth/#{params[:provider]}?redirect=#{params[:callback]}"
  end


  def create
    user = User.find_or_create_from_auth(request.env['omniauth.auth'])
    token = user.token
    url = request.env['omniauth.params']['redirect']
    redirect_to "#{url}?token=#{token}"
  end


  def destroy
    @auth_user.regenerate_token
    @auth_user.save!
    render json: {}
  end


  def failure
    #raise CustomError::Unauthorized
    redirect_to request.env['omniauth.params']['redirect']
  end
end
