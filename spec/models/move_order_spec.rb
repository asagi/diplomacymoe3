# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MoveOrder, type: :model do
  describe '#to_s' do
    example "仏の par 陸軍の pic への移動命令は 'A par-pic'" do
      @power = Power.create(symbol: Power::F)
      @unit = Unit.create(
        type: Army.to_s,
        power: @power,
        phase: 'spr_1st',
        prov_code: 'par'
      )
      expect(
        MoveOrder.new(power: @power, unit: @unit, dest: 'pic').to_s
      ).to eq 'A par-pic'
    end
  end
end
