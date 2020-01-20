class CreateTableForm
  include ActiveModel::Model

  attr_reader :owner, :desired_power
  attr_reader :face_type, :period_rule, :duration, :juggling, :due_date, :start_time, :private, :keyword

  validates :owner, presence: true
  validates :desired_power, inclusion: { in: ["", "a", "e", "f", "g", "i", "r", "t"] }
  validates :face_type, presence: true
  validates :period_rule, presence: true
  validates :duration, presence: true
  validates :juggling, presence: true
  validates :due_date, presence: true, format: { with: /\d{4}-\d{2}-\d{2}/ }
  validates :start_time, presence: true, format: { with: /\d{1,2}:\d{2}/ }
  validates :private, inclusion: { in: [true, false] }
  validates :keyword, presence: true, if: :private

  validate :check_start_datetime

  def initialize(owner:, params:)
    @owner = owner
    @desired_power = params[:desired_power]
    @face_type = params[:face_type]
    @period_rule = params[:period_rule]
    @duration = params[:duration]
    @juggling = params[:juggling]
    @due_date = params[:due_date]
    @start_time = params[:start_time]
    @private = params[:private]
    @keyword = params[:keyword]
    super()
  end

  def save
    return false if invalid?

    owner_params = {
      user: @owner,
      desired_power: @desired_power,
    }
    regulation_params = {
      face_type: @facetype,
      period_rule: @period_rule,
      duration: @duration,
      juggling: @juggling,
      due_date: @due_date,
      start_time: @start_time,
      private: @private,
      keyword: @keyword,
    }
    @regulation = Regulation.create(regulation_params)
    CreateInitializedTableService.call(owner: owner_params, regulation: @regulation)
  end

  private

  def check_start_datetime
    min_start_datetime = Time.zone.now + 1.hours
    start_datetime = Time.zone.parse("%sT%s:00+09:00" % [@due_date, ("0" + @start_time)[-5..5]])

    if min_start_datetime > start_datetime
      errors.add(:start_time, "is invalid")
    end
  end
end
