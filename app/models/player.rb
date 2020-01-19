class Player < ApplicationRecord
  belongs_to :user
  belongs_to :power, optional: true

  def initialize(user:, power: nil, desired_power: "")
    super
  end
end
