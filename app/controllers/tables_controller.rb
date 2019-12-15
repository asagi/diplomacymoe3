class TablesController < ApplicationController
  before_action :authenticate, only: [:create]

  def index
    @tables = Table.all
    render json: @tables
  end

  def create
    @regulation = Regulation.create(regulation_params)
    @table = CreateInitializedTableService.call(user: @auth_user, regulation: @regulation)
    render json: @table.to_json(include: [:regulation])
  end

  def regulation_params
    p params
    params.require(:regulation).permit(:face_type, :period_rule, :duration, :keyword, :due_date, :start_time)
  end
end
