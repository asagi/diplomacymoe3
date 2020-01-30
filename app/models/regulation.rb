# frozen_string_literal: true

class Regulation < ApplicationRecord
  has_one :table

  enum face_type: {
    girl: 0,
    flag: 1
  }, _prefix: false

  module FaceType
    GIRL = 'girl'
    FLAG = 'flag'
  end

  module PeriodRule
    # next_period は更新時刻以降に呼ばれるものとする

    module Fixed
      def period_rule
        'fixed'
      end

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
      def period_rule
        'flexible'
      end

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
    module Short
      def duration
        'short'
      end

      def negotiation_time
        60 * 60
      end

      def cleanup_time
        60 * 15
      end
    end

    module Standard
      def duration
        'standard'
      end

      def negotiation_time
        60 * 60 * 24
      end

      def cleanup_time
        60 * 30
      end
    end
  end

  def initialize(options = {})
    options ||= {}
    options[:face_type] ||= FaceType::GIRL
    options[:period_rule] ||= Const.regulation.period_rule.fixed
    options[:duration] ||= Const.regulation.duration.standard
    super
  end

  def period_rule_module
    if period_rule == Const.regulation.period_rule.fixed
      PeriodRule::Fixed
    else
      PeriodRule::Flexible
    end
  end

  def duration_module
    if duration == Const.regulation.duration.standard
      Duration::Standard
    else
      Duration::Short
    end
  end

  def first_period
    format('%<date>s %<time>s', date: due_date, time: start_time)
  end
end
