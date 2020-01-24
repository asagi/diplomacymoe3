# frozen_string_literal: true

class Table < ApplicationRecord
  has_many :turns
  has_many :powers
  has_many :players
  belongs_to :regulation, optional: true

  enum status: {
    created: 0,
    discarded: 1,
    ready: 2,
    started: 3,
    draw: 4,
    solo: 5,
    closed: 6
  }, _prefix: true

  enum phase: {
    spr_1st: 0,
    spr_2nd: 1,
    fal_1st: 2,
    fal_2nd: 3,
    fal_3rd: 4
  }, _prefix: true

  module Phase
    SPR_1ST = 'spr_1st'
    SPR_2ND = 'spr_2nd'
    FAL_1ST = 'fal_1st'
    FAL_2ND = 'fal_2nd'
    FAL_3RD = 'fal_3rd'
  end

  NEXT_PHASE = {
    Phase::SPR_1ST => Phase::SPR_2ND,
    Phase::SPR_2ND => Phase::FAL_1ST,
    Phase::FAL_1ST => Phase::FAL_2ND,
    Phase::FAL_2ND => Phase::FAL_3RD,
    Phase::FAL_3RD => Phase::SPR_1ST
  }.freeze

  LAST_PHASE = {
    Phase::SPR_1ST => Phase::FAL_3RD,
    Phase::SPR_2ND => Phase::SPR_1ST,
    Phase::FAL_1ST => Phase::SPR_2ND,
    Phase::FAL_2ND => Phase::FAL_1ST,
    Phase::FAL_3RD => Phase::FAL_2ND
  }.freeze

  class NoPlaceAvailableError < StandardError; end

  after_initialize do
    next unless regulation

    extend regulation.face_type_module
    extend regulation.period_rule_module
    extend regulation.duration_module
    status_created! unless status
  end

  def initialize(options = {})
    options ||= { turn: 0, phase: 0 }
    options[:turn] ||= 0
    options[:phase] ||= 0
    super
  end

  def full?
    return unless status_created?

    # 管理人を除いて 7 人
    players.joins(:user).where(users: { admin: false }).size == 7
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
    status_discarded!
    self
  end

  def start
    proceed
    self.period = next_period(next_phase: phase) if regulation
    status_started!
    self
  end

  def draw
    turn = turns.find_by(number: self.turn).next
    turns << turn
    self.turn = turn.number
    phase_spr_1st!
    self.period = last_nego_period + (60 * 60 * 24)
    status_draw!
    self
  end

  def solo
    turn = turns.find_by(number: self.turn).next
    turns << turn
    self.turn = turn.number
    phase_spr_1st!
    self.period = last_nego_period + (60 * 60 * 24)
    status_solo!
    self
  end

  def close
    proceed
    phase_spr_1st!
    self.period = next_period(next_phase: phase) if regulation
    status_closed!
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
