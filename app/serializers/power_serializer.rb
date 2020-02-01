# frozen_string_literal: true

class PowerSerializer < ActiveModel::Serializer
  attribute :id
  attribute :table_id
  attribute :player_id
  attribute :symbol
  attribute :name
  attribute :genitive
  attribute :jname

  def player_id
    object.player&.id
  end
end
