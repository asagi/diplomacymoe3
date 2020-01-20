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

  STATUS_NAME = {}
  STATUS_NAME[CREATED] = "CREATED"
  STATUS_NAME[DISCARDED] = "DISCARDED"
  STATUS_NAME[READY] = "READY"
  STATUS_NAME[STARTED] = "STARTED"
  STATUS_NAME[DRAW] = "DRAW"
  STATUS_NAME[SOLO] = "SOLO"
  STATUS_NAME[CLOSED] = "CLOSED"

  def self.status_text(code:)
    STATUS_NAME[code]
  end

  def status_text
    self.class.status_text(code: self.status)
  end

  after_initialize do
    next unless self.regulation
    self.extend self.regulation.face_type_module
    self.extend self.regulation.period_rule_module
    self.extend self.regulation.duration_module
    self.status ||= CREATED
  end

  def initialize(options = {})
    options = { turn: 0, phase: 0 } unless options
    options[:turn] ||= 0
    options[:phase] ||= 0
    super
  end

  def full?
    # 管理人を除いて 7 人
    case self.status
    when CREATED
      self.players.joins(:user).where(users: { admin: false }).size == 7
    end
  end

  def add_master
    self.players.create(user: nil, power: self.powers.find_by(symbol: "x"))
    self
  end

  def add_player(user:, desired_power: "")
    self.players.create(user: user, desired_power: desired_power)
    self
  end

  def current_turn
    self.turns.find_by(number: self.turn)
  end

  def last_turn
    self.turns.find_by(number: self.turn - 1)
  end

  def last_phase_units
    case self.phase
    when Const.phases.spr_1st
      turn = self.turns.find_by(number: self.turn - 1)
      turn.units.where(phase: Const.phases.fal_3rd)
    when Const.phases.spr_2nd
      current_turn.units.where(phase: Const.phases.spr_1st)
    when Const.phases.fal_1st
      current_turn.units.where(phase: Const.phases.spr_2nd)
    when Const.phases.fal_2nd
      current_turn.units.where(phase: Const.phases.fal_1st)
    when Const.phases.fal_3rd
      current_turn.units.where(phase: Const.phases.fal_2nd)
    end
  end

  def proceed
    case self.phase
    when Const.phases.spr_1st
      self.phase = Const.phases.spr_2nd
    when Const.phases.spr_2nd
      self.phase = Const.phases.fal_1st
    when Const.phases.fal_1st
      self.phase = Const.phases.fal_2nd
    when Const.phases.fal_2nd
      self.phase = Const.phases.fal_3rd
    when Const.phases.fal_3rd
      turn = turns.find_by(number: self.turn).next
      turns << turn
      self.turn = turn.number
      self.phase = Const.phases.spr_1st
    end
    self.period = self.next_period(next_phase: self.phase) if regulation
    save!
    self
  end

  def discard
    self.status = DISCARDED
    self
  end

  def start
    self.proceed
    self.period = self.next_period(next_phase: self.phase) if regulation
    self.status = STARTED
    self
  end

  def draw
    turn = turns.find_by(number: self.turn).next
    turns << turn
    self.turn = turn.number
    self.phase = Const.phases.spr_1st
    self.period = self.last_nego_period + (60 * 60 * 24)
    self.status = DRAW
    self
  end

  def solo
    turn = turns.find_by(number: self.turn).next
    turns << turn
    self.turn = turn.number
    self.phase = Const.phases.spr_1st
    self.period = self.last_nego_period + (60 * 60 * 24)
    self.status = SOLO
    self
  end

  def close
    self.proceed
    self.phase = Const.phases.spr_1st
    self.period = self.next_period(next_phase: self.phase) if regulation
    self.status = CLOSED
    self
  end

  def order_targets
    return Unit.none if self.turn == Const.turns.initial
    number = self.turn
    number -= 1 if self.phase == Const.phases.spr_1st
    turn = turns.find_by(number: number)
    turn.units
  end
end
