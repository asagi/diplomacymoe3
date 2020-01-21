# frozen_string_literal: true

class Turn < ApplicationRecord
  belongs_to :table
  has_many :provinces
  has_many :units
  has_many :orders, before_add: :set_phase

  def initialize(options = {})
    options ||= { number: table.number }
    options[:number] ||= Const.turns.initial
    super
  end

  def next
    table.turns.build(number: number + 1)

    # 地域情報を引き継ぎ

    # ユニット情報を引き継ぎ
  end

  private

  def set_phase(order)
    order.phase = table.phase
  end
end
