# frozen_string_literal: true

class TableSerializer < ActiveModel::Serializer
  attributes :id
  attributes :number
  has_one :owner
  has_many :players
  has_one :regulation
  attributes :status
  attributes :turn
  attributes :phase
  attributes :period
end
