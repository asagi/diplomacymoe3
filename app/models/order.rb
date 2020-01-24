# frozen_string_literal: true

class Order < ApplicationRecord
  belongs_to :turn
  belongs_to :power
  belongs_to :unit

  attr_accessor :support

  enum phase: Table.phases

  UNSLOVED = 0
  FAILED = 1
  SUCCEEDED = 2
  APPLIED = 3
  DISLODGED = 4
  REJECTED = 5
  CUT = 6

  STATUS_NAME = {
    UNSLOVED: 'UNSLOVED',
    FAILED: 'FAILED',
    SUCCEEDED: 'SUCCEEDED',
    APPLIED: 'APPLIED',
    DISLODGED: 'DISLODGED',
    REJECTED: 'REJECTED',
    CUT: 'CUT'
  }.freeze

  after_initialize do
    self.status ||= UNSLOVED
  end

  def self.status_text(code:)
    STATUS_NAME[code]
  end

  def status_text
    self.class.status_text(code: self.status)
  end

  def to_key
    keys = []
    keys << power.symbol
    keys << unit_kind.downcase
    keys << unit.province
    keys << dest if dest
    keys.join('-')
  end

  def hold?
    false
  end

  def move?
    false
  end

  def support?
    false
  end

  def convoy?
    false
  end

  def retreat?
    false
  end

  def disband?
    false
  end

  def gain?
    false
  end

  def lose?
    false
  end

  def unsloved?
    self.status == UNSLOVED
  end

  def succeed
    self.status = SUCCEEDED
  end

  def succeeded?
    self.status == SUCCEEDED
  end

  def apply
    self.status = APPLIED
  end

  def applied?
    self.status == APPLIED
  end

  def fail
    self.status = FAILED
    self.support = 0
  end

  def failed?
    self.status == FAILED
  end

  def dislodge(against:)
    self.status = DISLODGED
    self.keepout = against.unit.province[0, 3]
  end

  def dislodged?
    self.status == DISLODGED
  end

  def reject
    self.status = REJECTED
  end

  def rejected?
    self.status == REJECTED
  end

  def cut?
    self.status == CUT
  end

  private

  def unit_kind
    unit.type[0]
  end

  def formated_target
    keys = target.split('-')
    format(
      '%<unit_power>s%<unit_kind>s %<unit_from>s%<unit_to>s',
      unit_power: target_unit_power(keys[0]),
      unit_kind: keys[1].upcase,
      unit_from: keys[2],
      unit_to: (keys[3] ? '-' + keys[3] : '')
    )
  end

  def target_unit_power(unit_power)
    unit_power == power.symbol ? '' : Powers[unit_power]['genitive'] + ' '
  end
end
