# frozen_string_literal: true

class TableSerializer < ActiveModel::Serializer
  attribute :id
  attribute :number
  has_one :owner
  has_one :regulation
  attribute :status
  attribute :turn
  attribute :phase
  attribute :period
  has_many :powers
  has_many :players
  has_many :units
  has_many :territories

  def phase
    object.turn.positive? ? object.phase : nil
  end

  def units
    object.last_phase_units
  end

  def territories
    object.last_turn_occupides
  end
end
