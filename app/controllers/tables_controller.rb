class TablesController < ApplicationController
  wrap_parameters :table,
                  include: [
                    :face_type,
                    :period_rule,
                    :duration,
                    :juggling,
                    :due_date,
                    :start_time,
                    :private,
                    :keyword,
                    :desired_power,
                  ]

  before_action :authenticate, only: [:create]
  before_action :set_table, only: [:show, :update, :destroy]

  def index
    @tables = Table.all
    render json: @tables
  end

  def show
    render json: @table
  end

  def create
    create_table = CreateTableForm.new(owner: @auth_user, params: create_table_params)
    if @table = create_table.save
      response.headers["Location"] = table_path(@table)
      render status: :created, json: { id: @table.id }
    else
      raise CustomError::BadRequest, create_table.errors.messages.to_json
    end
  end

  private

  def create_table_params
    params.require(:table)
      .permit(
        :face_type,
        :period_rule,
        :duration,
        :juggling,
        :due_date,
        :start_time,
        :private,
        :keyword,
        :desired_power
      )
  end

  def set_table
    @table = Table.find(params[:id])
  end
end
