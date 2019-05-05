class Regulation < ApplicationRecord
  has_one :table

  module FaceType
    module Girl
      # TODO
      def face_type; "girl" end
    end

    module Flag
      # TODO
      def face_type; "flag" end
    end
  end


  module PeriodRule
    # next_period は更新時刻以降に呼ばれるものとする

    module Fixed
      def next_period(next_phase:)
        now = Time.zone.now

        case next_phase
        when Const.phases.spr_1st, Const.phases.fal_1st
          # 外交フェイズ
          result = self.last_nego_period + self.negotiation_time
          return result.strftime("%Y-%m-%d %H:%M")
        else
          # 処理フェイズ
          return (now + self.cleanup_time).strftime("%Y-%m-%d %H:%M")
        end
      end
    end

    module Flexible
      def next_period(next_phase:)
        now = Time.zone.now

        case next_phase
        when Const.phases.spr_1st, Const.phases.fal_1st
          # 外交フェイズ
          return (now + self.negotiation_time).strftime("%Y-%m-%d %H:%M")
        else
          # 処理フェイズ
          return (now + self.cleanup_time).strftime("%Y-%m-%d %H:%M")
        end
      end
    end
  end


  module Duration
    module Short
      def negotiation_time; 60 * 60 end
      def cleanup_time; 60 * 15 end
    end

    module Standard
      def negotiation_time; 60 * 60 * 24 end
      def cleanup_time; 60 * 30 end
    end
  end


  def initialize(options = {})
    options = {} unless options
    options[:face_type] ||= Const.regulation.face_type.girl
    options[:period_rule] ||= Const.regulation.period_rule.fixed
    options[:duration] ||= Const.regulation.duration.standard
    super
  end


  def face_type_module
    if self.face_type == Const.regulation.face_type.girl
      FaceType::Girl
    else
      FaceType::Flag
    end
  end


  def period_rule_module
    if self.period_rule == Const.regulation.period_rule.fixed
      PeriodRule::Fixed
    else
      PeriodRule::Flexible
    end
  end


  def duration_module
    if self.duration == Const.regulation.duration.standard
      Duration::Standard
    else
      Duration::Short
    end
  end


  def first_period
    "%s %s"%[self.due_date, self.start_time]
  end
end
