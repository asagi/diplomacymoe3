# frozen_string_literal: true

class TableSerializer < ActiveModel::Serializer
  attribute :id
  attribute :number
  has_one :owner
  has_many :players
  has_one :regulation
  attribute :status
  attribute :turn
  attribute :phase
  attribute :period

  def players
    object.players.select(&:user)
  end
end
