# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :authenticate, only: [:show]

  def show
    render json: @auth_user
  end
end
