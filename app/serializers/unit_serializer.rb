# frozen_string_literal: true

class UnitSerializer < ActiveModel::Serializer
  attribute :id
  attribute :kind
  attribute :province
  attribute :keepout
  attribute :owner

  def turn
    object.turn.number
  end

  def phase
    object.turn.number.positive? ? object.phase : nil
  end

  def owner
    object.power.symbol
  end
end
