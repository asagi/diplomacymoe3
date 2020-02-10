# frozen_string_literal: true

class CreateTableForm
  include ActiveModel::Model

  attr_reader :owner
  attr_reader :desired_power
  attr_reader :face_type
  attr_reader :period_rule
  attr_reader :duration
  attr_reader :juggling
  attr_reader :due_date
  attr_reader :start_time
  attr_reader :private
  attr_reader :keyword
  attr_accessor :table

  validates :owner, presence: true
  validates :desired_power, inclusion: {
    in: ['', 'a', 'e', 'f', 'g', 'i', 'r', 't']
  }
  validates :face_type,
            presence: true,
            inclusion: {
              in: Regulation.face_types.keys
            }
  validates :period_rule,
            presence: true,
            inclusion: {
              in: Regulation.period_rules.keys
            }
  validates :duration,
            presence: true,
            inclusion: {
              in: Regulation.durations.keys
            }
  validates :juggling,
            presence: true,
            inclusion: {
              in: Regulation.jugglings.keys
            }
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
    return false unless permitted?
    return false if invalid?

    owner_params = {
      user: @owner,
      desired_power: @desired_power
    }
    regulation_params = {
      face_type: @face_type,
      period_rule: @period_rule,
      duration: @duration,
      juggling: @juggling,
      due_date: @due_date,
      start_time: @start_time,
      private: @private,
      keyword: @keyword
    }
    @regulation = Regulation.create(regulation_params)
    @table = CreateInitializedTableService.call(
      owner: owner_params,
      regulation: @regulation
    )
    true
  end

  private

  def permitted?
    @owner.tables.each do |t|
      next if t.status_closed?
      next if t.status_discarded?
      next if t.status_solo?
      next if t.status_draw?

      errors[:base] << 'Owner is not permitted to create tables.'
      return false
    end
    true
  end

  def check_start_datetime
    min_start_datetime = Time.zone.now + 1.hours
    start_datetime = Time.zone.parse(
      format(
        '%<date>sT%<time>s:00+09:00',
        date: @due_date,
        time: ('0' + @start_time)[-5..5]
      )
    )

    errors.add(:start_time, 'is invalid') if min_start_datetime > start_datetime
  end
end
