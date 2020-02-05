# frozen_string_literal: true

class UnitSerializer < ActiveModel::Serializer
  attribute :id
  attribute :kind
  attribute :prov_code
  attribute :keepout
  attribute :owner

  def phase
    object.turn.number.positive? ? object.phase : nil
  end

  def owner
    object.power.symbol
  end
end
