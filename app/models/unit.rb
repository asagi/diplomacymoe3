# frozen_string_literal: true

class Unit < ApplicationRecord
  belongs_to :turn
  belongs_to :power
  has_many :orders

  enum phase: Table.phases

  def army?
    false
  end

  def fleet?
    false
  end

  def owner
    power.symbol
  end

  def kind
    type.to_s[0].downcase
  end

  def prov_key
    province[0, 3]
  end
end
