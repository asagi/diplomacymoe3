# frozen_string_literal: true

class Order < ApplicationRecord
  belongs_to :turn
  belongs_to :power
  belongs_to :unit

  attr_accessor :supports

  enum phase: Table.phases

  enum status: {
    unsloved: 0,
    failed: 1,
    succeeded: 2,
    applied: 3,
    missed: 4,
    dislodged: 5,
    rejected: 6,
    cut: 7
  }, _prefix: true

  module Status
    UNSLOVED = 'unsloved'
    FAILED = 'failed'
    SUCCEEDED = 'succeeded'
    APPLIED = 'applied'
    MISSED = 'missed'
    DISLODGED = 'dislodged'
    REJECTED = 'rejected'
    CUT = 'cut'
  end

  after_initialize do
    unslove unless status
  end

  def prevent_save
    raise Exception, "Don't save order now"
  end

  def to_key
    keys = []
    keys << power.symbol
    keys << unit_kind.downcase
    keys << unit.province
    keys << dest if dest
    keys.join('-')
  end

  def from
    unit.province
  end

  def assumed?
    power != unit.power
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

  def unslove
    self.status = Status::UNSLOVED
  end

  def unsloved?
    status == Status::UNSLOVED
  end

  def succeed
    self.status = Status::SUCCEEDED
  end

  def succeeded?
    status == Status::SUCCEEDED
  end

  def apply
    self.status = Status::APPLIED
  end

  def applied?
    status == Status::APPLIED
  end

  def cut
    self.status = Status::CUT
  end

  def cut?
    status == Status::CUT
  end

  def fail
    self.status = Status::FAILED
    self.supports = 0
  end

  def failed?
    status == Status::FAILED
  end

  def dislodge(against: nil)
    self.status = Status::DISLODGED
    self.keepout = against.unit.prov_key if against
  end

  def dislodged?
    status == Status::DISLODGED
  end

  def miss
    self.status = Status::MISSED
  end

  def missed?
    status == Status::MISSED
  end

  def reject
    self.status = Status::REJECTED
  end

  def rejected?
    status == Status::REJECTED
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
