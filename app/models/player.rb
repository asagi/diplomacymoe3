# frozen_string_literal: true

class Player < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :power, optional: true

  def initialize(user:, power: nil, desired_power: '')
    super
  end
end
