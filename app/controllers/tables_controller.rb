class TablesController < ApplicationController
  wrap_parameters :regulation,
                  include: [
                    :face_type,
                    :period_rule,
                    :duration,
                    :due_date,
                    :start_time,
                    :private,
                    :keyword,
                    :power,
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
    @regulation = Regulation.create(regulation_params)
    @table = CreateInitializedTableService.call(user: @auth_user, regulation: @regulation)
    head :created, location: table_path(@table)
  end

  def regulation_params
    params.require(:regulation).permit(:face_type, :period_rule, :duration, :keyword, :due_date, :start_time)
  end

  private

  def set_table
    @table = Table.find(params[:id])
  end
end
