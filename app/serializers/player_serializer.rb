# frozen_string_literal: true

class PlayerSerializer < ActiveModel::Serializer
  attribute :id
  attribute :table_id
  belongs_to :user
  attribute :desired_power
  attribute :power
  attribute :status
  # attribute :registered_at
  # attribute :leaved_at

  def power
    object.power&.symbol || ''
  end
end
