# frozen_string_literal: true

class Table < ApplicationRecord
  has_many :turns
  has_many :powers
  has_many :players
  belongs_to :regulation, optional: true

  CREATED = 0
  DISCARDED = 1
  READY = 2
  STARTED = 3
  DRAW = 4
  SOLO = 5
  CLOSED = 6

  STATUS_NAME = {
    CREATED: 'CREATED',
    DISCARDED: 'DISCARDED',
    READY: 'READY',
    STARTED: 'STARTED',
    DRAW: 'DRAW',
    SOLO: 'SOLO',
    CLOSED: 'CLOSED'
  }.freeze

  enum phase: {
    spr_1st: 0,
    spr_2nd: 1,
    fal_1st: 2,
    fal_2nd: 3,
    fal_3rd: 4
  }, _prefix: true

  NEXT_PHASE = {
    'spr_1st' => 'spr_2nd',
    'spr_2nd' => 'fal_1st',
    'fal_1st' => 'fal_2nd',
    'fal_2nd' => 'fal_3rd',
    'fal_3rd' => 'spr_1st'
  }.freeze

  LAST_PHASE = {
    'spr_1st' => 'fal_3rd',
    'spr_2nd' => 'spr_1st',
    'fal_1st' => 'spr_2nd',
    'fal_2nd' => 'fal_1st',
    'fal_3rd' => 'fal_2nd'
  }.freeze

  class NoPlaceAvailableError < StandardError; end

  def self.status_text(code:)
    STATUS_NAME[code]
  end

  def status_text
    self.class.status_text(code: status)
  end

  after_initialize do
    next unless regulation

    extend regulation.face_type_module
    extend regulation.period_rule_module
    extend regulation.duration_module
    self.status ||= CREATED
  end

  def initialize(options = {})
    options ||= { turn: 0, phase: 0 }
    options[:turn] ||= 0
    options[:phase] ||= 0
    super
  end

  def full?
    # 管理人を除いて 7 人
    case self.status
    when CREATED
      players.joins(:user).where(users: { admin: false }).size == 7
    end
  end

  def add_master
    players.create(user: nil, power: powers.find_by(symbol: 'x'))
    self
  end

  def add_player(user:, desired_power: '')
    with_lock do
      raise NoPlaceAvailableError if full?

      players.create(user: user, desired_power: desired_power)
    end
    self
  end

  def last_phase_units
    turn = phase_spr_1st? ? last_turn : current_turn
    turn.units.where(phase: LAST_PHASE[phase])
  end

  def current_turn
    turns.find_by(number: turn)
  end

  def last_turn
    turns.find_by(number: turn - 1)
  end

  def proceed
    self.phase = NEXT_PHASE[phase]
    proceed_phase if phase_spr_1st?
    self.period = next_period(next_phase: phase) if regulation
    save!
    self
  end

  def discard
    self.status = DISCARDED
    self
  end

  def start
    proceed
    self.period = next_period(next_phase: phase) if regulation
    self.status = STARTED
    self
  end

  def draw
    turn = turns.find_by(number: self.turn).next
    turns << turn
    self.turn = turn.number
    phase_spr_1st!
    self.period = last_nego_period + (60 * 60 * 24)
    self.status = DRAW
    self
  end

  def solo
    turn = turns.find_by(number: self.turn).next
    turns << turn
    self.turn = turn.number
    phase_spr_1st!
    self.period = last_nego_period + (60 * 60 * 24)
    self.status = SOLO
    self
  end

  def close
    proceed
    phase_spr_1st!
    self.period = next_period(next_phase: phase) if regulation
    self.status = CLOSED
    self
  end

  def order_targets
    return Unit.none if turn == Const.turns.initial

    number = turn
    number -= 1 if phase_spr_1st?
    turn = turns.find_by(number: number)
    turn.units
  end

  private

  def proceed_phase
    turn = turns.find_by(number: self.turn).next
    turns << turn
    self.turn = turn.number
  end
end
