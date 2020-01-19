class TablesController < ApplicationController
  wrap_parameters :regulation,
                  include: [
                    :face_type,
                    :period_rule,
                    :duration,
                    :juggling,
                    :due_date,
                    :start_time,
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
    @owner = {
      user: @auth_user,
      desired_power: "",
    }
    @regulation = Regulation.create(regulation_params)
    @table = CreateInitializedTableService.call(owner: @owner, regulation: @regulation)
    response.headers["Location"] = table_path(@table)
    render status: :created, json: { id: @table.id }
  end

  def regulation_params
    params.require(:regulation)
      .permit(
        :face_type,
        :period_rule,
        :duration,
        :juggling,
        :keyword,
        :due_date,
        :start_time
      )
  end

  private

  def set_table
    @table = Table.find(params[:id])
  end
end
