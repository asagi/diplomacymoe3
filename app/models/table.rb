class Table < ApplicationRecord
  has_many :turns
  has_many :powers

  def initialize(options = {})
    options = {turn: 0, phase: 0} unless options
    options[:turn] ||= 0
    options[:phase] ||= 0
    super
  end


  def proceed
    if self.phase == Const.phases.final
      turn = turns.find_by(number: self.turn).next
      turns << turn
      self.turn = turn.number
      self.phase = Const.phases.spr_1st
    else
      self.phase += 1
    end
    save!
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
