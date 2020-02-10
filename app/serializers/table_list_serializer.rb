# frozen_string_literal: true

class TableListSerializer < ActiveModel::Serializer
  attribute :id
  attribute :number
  has_one :owner
  has_one :regulation
  attribute :status
  attribute :turn_number
  attribute :phase
  attribute :period
  has_many :players

  def phase
    object.turn_number.positive? ? object.phase : nil
  end

  def units
    object.last_phase_units
  end

  def territories
    object.last_turn_occupides
  end
end
