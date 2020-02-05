# frozen_string_literal: true

module TableHelper
  def override_proceed(table:)
    table.define_singleton_method(:proceed) do
      self.phase = Table::NEXT_PHASE[phase]
      proceed_turn if phase_spr_1st?
      tap(&:save!)
    end
  end
end
