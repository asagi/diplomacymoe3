# frozen_string_literal: true

class TablesController < ApplicationController
  before_action :authenticate, only: [:create]
  before_action :set_table, only: %i[show update destroy]

  def index
    @tables = Table.all
    render json: @tables
  end

  def show
    render json: @table
  end

  def create
    create_table = CreateTableForm.new(owner: @auth_user, params: params)
    if create_table.save
      table = create_table.table
      response.headers['Location'] = table_path(table)
      render status: :created, json: { id: table.id }
    else
      raise CustomError::BadRequest, create_table.errors.messages.to_json
    end
  end

  private

  def set_table
    @table = Table.find(params[:id])
  end
end
