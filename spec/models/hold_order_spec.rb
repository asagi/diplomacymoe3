require 'rails_helper'

RSpec.describe HoldOrder, type: :model do
  describe '#to_s' do
    example "仏の par 陸軍の維持命令は 'A par H'"  do
      @power = Power.create(symbol: Power::F)
      @unit = Unit.create(type: Army.to_s, power: @power, phase: 0, province: 'par')
      expect(HoldOrder.new(power: @power, unit: @unit).to_s).to eq 'A par H'
    end
  end
end
