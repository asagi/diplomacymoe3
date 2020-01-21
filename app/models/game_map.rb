# frozen_string_literal: true

class GameMap < ApplicationRecord
  belongs_to :turn

  after_initialize do
  end
end
