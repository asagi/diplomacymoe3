# frozen_string_literal: true

module TableHelper
  def override_proceed(table:)
    table.define_singleton_method(:proceed) do
      self.phase = Table::NEXT_PHASE[phase]
      proceed_phase if phase == Const.phases.spr_1st
      save!
      self
    end
  end
end
