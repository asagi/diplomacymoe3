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

  def phase
    object.turn.positive? ? object.phase : nil
  end
end
