class TablesController < ApplicationController
  wrap_parameters :create_table,
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
    @owner = { user: @auth_user }.merge(owner_params.to_h)
    @regulation = Regulation.create(regulation_params)
    @table = CreateInitializedTableService.call(owner: @owner, regulation: @regulation)
    response.headers["Location"] = table_path(@table)
    render status: :created, json: { id: @table.id }
  end

  private

  def owner_params
    params.require(:create_table)
      .permit(
        :desired_power
      )
  end

  def regulation_params
    params.require(:create_table)
      .permit(
        :face_type,
        :period_rule,
        :duration,
        :juggling,
        :keyword,
        :due_date,
        :start_time,
        :private,
        :keyword
      )
  end

  def set_table
    @table = Table.find(params[:id])
  end
end
