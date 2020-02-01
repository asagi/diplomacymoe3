# frozen_string_literal: true

class RegulationSerializer < ActiveModel::Serializer
  attribute :id
  attribute :face_type
  attribute :period_rule
  attribute :duration
  attribute :private
  attribute :keyword
  attribute :due_date
  attribute :start_time
  attribute :juggling
end
