# frozen_string_literal: true

class Regulation < ApplicationRecord
  has_one :table

  enum face_type: {
    girl: 0,
    flag: 1
  }, _prefix: false

  enum period_rule: {
    fixed: 0,
    flexible: 1
  }, _prefix: false

  enum duration: {
    short: 0,
    standard: 1
  }, _prefix: false

  enum juggling: {
    allow: 0,
    disallow: 1
  }, _prefix: false

  module FaceType
    GIRL = 'girl'
    FLAG = 'flag'
  end

  module PeriodRule
    FIXED = 'fixed'
    FLEXIBLE = 'flexible'

    module Fixed
      # next_period は更新時刻以降に呼ばれるものとする
      def next_period(next_phase:)
        case next_phase
        when Table::Phase::SPR_1ST, Table::Phase::FAL_1ST
          # 外交フェイズ
          result = (last_nego_period || period) + negotiation_time
          self.last_nego_period = period
          result
        else
          # 処理フェイズ
          Time.zone.now + cleanup_time
        end.strftime('%Y-%m-%d %H:%M')
      end
    end

    module Flexible
      # next_period は更新時刻以降に呼ばれるものとする
      def next_period(next_phase:)
        now = Time.zone.now

        case next_phase
        when Table::Phase::SPR_1ST, Table::Phase::FAL_1ST
          # 外交フェイズ
          (now + negotiation_time).strftime('%Y-%m-%d %H:%M')
        else
          # 処理フェイズ
          (now + cleanup_time).strftime('%Y-%m-%d %H:%M')
        end
      end
    end
  end

  module Duration
    SHORT = 'short'
    STANDARD = 'standard'

    module Short
      def negotiation_time
        60 * 60
      end

      def cleanup_time
        60 * 15
      end
    end

    module Standard
      def negotiation_time
        60 * 60 * 24
      end

      def cleanup_time
        60 * 30
      end
    end
  end

  module Juggling
    ALLOW = 'allow'
    DISALLOW = 'disallow'
  end

  def initialize(options = {})
    options ||= {}
    options[:face_type] ||= FaceType::GIRL
    options[:period_rule] ||= PeriodRule::FIXED
    options[:duration] ||= Duration::STANDARD
    options[:juggling] ||= Juggling::ALLOW
    super
  end

  def period_rule_module
    case period_rule
    when PeriodRule::FIXED
      PeriodRule::Fixed
    when PeriodRule::FLEXIBLE
      PeriodRule::Flexible
    else
      raise
    end
  end

  def duration_module
    case duration
    when Duration::SHORT
      Duration::Short
    when Duration::STANDARD
      Duration::Standard
    else
      raise
    end
  end

  def first_period
    format('%<date>s %<time>s', date: due_date, time: start_time)
  end
end
