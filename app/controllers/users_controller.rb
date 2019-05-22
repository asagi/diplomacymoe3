class UsersController < ApplicationController
  wrap_parameters :user, include: [:name, :password, :password_confirmation]

  before_action :authenticate, only: [ :show ]


  def show
    p @auth_user
    render json: @auth_user
  end


  private
  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
