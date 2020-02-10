# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :authenticate, only: %i[show]
  before_action :set_user, only: %i[tables]

  def show
    render json: @auth_user
  end

  def tables
    raise CustomError::BadRequest, {} unless @user

    render json: @user.tables,
           each_serializer: TableListSerializer,
           include: '**'
  end

  def set_user
    id = params[:id]
    @user = User.find_by(id: id)
  end
end
