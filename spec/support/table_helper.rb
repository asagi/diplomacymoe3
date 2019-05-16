module TableHelper
  def override_proceed(table:)
    table.define_singleton_method(:proceed) do
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
      save!
      self
    end
  end
end
