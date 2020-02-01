# frozen_string_literal: true

class ProvinceSerializer < ActiveModel::Serializer
  attribute :id
  attribute :code
  attribute :power
  attribute :supplycenter
  attribute :name
  attribute :jname
end
