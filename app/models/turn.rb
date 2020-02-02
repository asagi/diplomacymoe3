# frozen_string_literal: true

class Turn < ApplicationRecord
  belongs_to :table
  has_many :provinces
  has_many :territories, -> { where.not(power: nil) }, class_name: :Province
  has_many :units
  has_many :orders, before_add: :current_phase_to

  def initialize(options = {})
    options ||= { number: table.number }
    options[:number] ||= Const.turns.initial
    super
  end

  def next
    table.turns.build(number: number + 1)

    # TODO: 地域情報を引き継ぎ

    # TODO: ユニット情報を引き継ぎ
  end

  def release_territoris_of(power)
    provinces.where(power: power.symbol).delete_all
  end

  def remove_units_of(power, phase)
    units.where(phase: phase).where(power: power).delete_all
  end

  def supply_centers_of(power)
    provinces
      .where(power: power.symbol)
      .where(supplycenter: true)
  end

  private

  def current_phase_to(order)
    order.phase = table.phase
  end
end
