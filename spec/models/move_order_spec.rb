require 'rails_helper'

RSpec.describe MoveOrder, type: :model do
  describe '#to_s' do
    example "仏の par 陸軍の pic への移動命令は 'A par-pic'" do
      @power = Power.create(symbol: Power::F)
      @unit = Unit.create(type: Army.to_s, power: Power::F, phase: 0, province: 'par')
      expect(MoveOrder.new(power: @power, unit: @unit, dest: 'pic').to_s).to eq 'A par-pic'
    end
  end
end
