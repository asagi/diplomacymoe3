# frozen_string_literal: true

class Player < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :power, optional: true
  belongs_to :table

  enum status: {
    active: 0,
    leaved: 1,
    kicked: 2,
    master: 9
  }, _prefix: false

  module Status
    ACTIVE = 'active'
    LEAVED = 'leaved'
    KICKED = 'kicked'
    MASTER = 'master'
  end

  def initialize(user:, power: nil, desired_power: '', status:)
    super
  end
end
