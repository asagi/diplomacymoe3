class UsersController < ApplicationController
  wrap_parameters :user, include: [:name, :password, :password_confirmation]

  # POST /users/login
  def login
    @user = User.find_by!(name: params[:name])
    if @user.authenticate(params[:password])
      render json: @user, status: 200
    else
      render json: @user.errors, status: :unauthorized
    end
  end

  # POST /users
  def create
    @user = User.new(user_params)
    if @user.save
      render json: @user, status: :created
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  private
  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
