require 'rails_helper'

RSpec.describe Regulation, type: :model do
  before :context do
    @user = User.find_or_create_by(uid: '12345')
  end

  let(:table) { CreateInitializedTableService.call(user: @user, regulation: @regulation) }

  describe '#create' do
    context "table への各レギュレーションモジュールの extend テスト" do
      context "初期値デフォルト" do
        before :context do
          @regulation = Regulation.create
        end

        example "フェイスタイプは 1" do
          expect(table.regulation.face_type).to eq 1
        end

        example "外交フェイズは 24 時間（60 * 60 * 24 秒）" do
          expect(table.negotiation_time).to eq 60 * 60 * 24
        end

        example "行軍解決後の処理フェイズは 30 分（60 * 30 秒）" do
          expect(table.cleanup_time).to eq 60 * 30
        end
      end

      context "初期値を明示的に指定" do
        before :context do
          options = {}
          options[:face_type] = Const.regulation.face_type.girl
          options[:period_rule] = Const.regulation.period_rule.fixed
          options[:duration] = Const.regulation.duration.standard
          @regulation = Regulation.create(options)
        end

        example "フェイスタイプは 1" do
          expect(table.regulation.face_type).to eq 1
        end

        example "外交フェイズは 24 時間（60 * 60 * 24 秒）" do
          expect(table.negotiation_time).to eq 60 * 60 * 24
        end

        example "行軍解決後の処理フェイズは 30 分（60 * 30 秒）" do
          expect(table.cleanup_time).to eq 60 * 30
        end
      end

      context "デフォルト値とは逆の初期値を指定" do
        before :context do
          options = {}
          options[:face_type] = Const.regulation.face_type.flag
          options[:period_rule] = Const.regulation.period_rule.flexible
          options[:duration] = Const.regulation.duration.short
          @regulation = Regulation.create(options)
        end

        example "フェイスタイプは 2" do
          expect(table.regulation.face_type).to eq 2
        end

        example "外交フェイズは 60 分（60 * 60 秒）" do
          expect(table.negotiation_time).to eq 60 * 60
        end

        example "行軍解決後の処理フェイズは 15 分（60 * 15 秒）" do
          expect(table.cleanup_time).to eq 60 * 15
        end
      end
    end
  end

  context "次フェイズの更新時刻取得" do
    context "中期卓" do
      context "固定制" do
        context "処理フェイズが日付を跨がない場合" do
          before :context do
            options = {}
            options[:period_rule] = Const.regulation.period_rule.fixed
            options[:duration] = Const.regulation.duration.standard
            options[:due_date] = "2019-05-04"
            options[:start_time] = "20:00"
            @regulation = Regulation.create(options)
          end

          example "開幕から春外交フェイズへ" do
            time = '2019-05-04 20:00'
            travel_to(time) do
              @table = table
              @table.last_nego_period = Time.zone.parse('2019-05-04 20:00')
              expect(@table.next_period(next_phase: Const.phases.spr_1st)).to eq "2019-05-05 20:00"
            end
          end

          example "春外交フェイズから春撤退フェイズへ" do
            time = '2019-05-05 20:00'
            travel_to(time) do
              @table = table
              @table.last_nego_period = Time.zone.parse('2019-05-05 20:00')
              expect(@table.next_period(next_phase: Const.phases.spr_2nd)).to eq "2019-05-05 20:30"
            end
          end

          example "春撤退フェイズから秋外交フェイズへ：早回し" do
            time = '2019-05-05 20:12'
            travel_to(time) do
              @table = table
              @table.last_nego_period = Time.zone.parse('2019-05-05 20:00')
              expect(@table.next_period(next_phase: Const.phases.fal_1st)).to eq "2019-05-06 20:00"
            end
          end

          example "春撤退フェイズから秋外交フェイズへ：定刻" do
            time = '2019-05-05 20:30'
            travel_to(time) do
              @table = table
              @table.last_nego_period = Time.zone.parse('2019-05-05 20:00')
              expect(@table.next_period(next_phase: Const.phases.fal_1st)).to eq "2019-05-06 20:00"
            end
          end

          example "秋外交フェイズから秋撤退フェイズへ" do
            time = '2019-05-06 20:00'
            travel_to(time) do
              @table = table
              @table.last_nego_period = Time.zone.parse('2019-05-06 20:00')
              expect(@table.next_period(next_phase: Const.phases.fal_2nd)).to eq "2019-05-06 20:30"
            end
          end

          example "秋撤退フェイズから秋調整フェイズへ：早回し" do
            time = '2019-05-06 20:08'
            travel_to(time) do
              @table = table
              @table.last_nego_period = Time.zone.parse('2019-05-06 20:00')
              expect(@table.next_period(next_phase: Const.phases.fal_3rd)).to eq "2019-05-06 20:38"
            end
          end

          example "秋撤退フェイズから秋調整フェイズへ：定刻" do
            time = '2019-05-06 20:30'
            travel_to(time) do
              @table = table
              @table.last_nego_period = Time.zone.parse('2019-05-06 20:00')
              expect(@table.next_period(next_phase: Const.phases.fal_3rd)).to eq "2019-05-06 21:00"
            end
          end

          example "秋調整フェイズから春外交フェイズへ：早回し" do
            time = '2019-05-06 20:38'
            travel_to(time) do
              @table = table
              @table.last_nego_period = Time.zone.parse('2019-05-06 20:00')
              expect(@table.next_period(next_phase: Const.phases.spr_1st)).to eq "2019-05-07 20:00"
            end
          end

          example "秋調整フェイズから春外交フェイズへ：撤退調整のいずれも定刻更新" do
            time = '2019-05-06 21:00'
            travel_to(time) do
              @table = table
              @table.last_nego_period = Time.zone.parse('2019-05-06 20:00')
              expect(@table.next_period(next_phase: Const.phases.spr_1st)).to eq "2019-05-07 20:00"
            end
          end
        end

        context "処理フェイズが日付を跨ぐ場合" do
          before :context do
            options = {}
            options[:period_rule] = Const.regulation.period_rule.fixed
            options[:duration] = Const.regulation.duration.standard
            options[:due_date] = "2019-05-04"
            options[:start_time] = "23:30"
            @regulation = Regulation.create(options)
          end

          example "開幕から春外交フェイズへ" do
            time = '2019-05-04 23:30'
            travel_to(time) do
              @table = table
              @table.last_nego_period = Time.zone.parse('2019-05-04 23:30')
              expect(@table.next_period(next_phase: Const.phases.spr_1st)).to eq "2019-05-05 23:30"
            end
          end

          example "春外交フェイズから春撤退フェイズへ" do
            time = '2019-05-05 23:30'
            travel_to(time) do
              @table = table
              @table.last_nego_period = Time.zone.parse('2019-05-05 23:30')
              expect(@table.next_period(next_phase: Const.phases.spr_2nd)).to eq "2019-05-06 00:00"
            end
          end

          example "春撤退フェイズから秋外交フェイズへ：早回し" do
            time = '2019-05-05 23:35'
            travel_to(time) do
              @table = table
              @table.last_nego_period = Time.zone.parse('2019-05-05 23:30')
              expect(@table.next_period(next_phase: Const.phases.fal_1st)).to eq "2019-05-06 23:30"
            end
          end

          example "春撤退フェイズから秋外交フェイズへ：定刻" do
            time = '2019-05-06 00:00'
            travel_to(time) do
              @table = table
              @table.last_nego_period = Time.zone.parse('2019-05-05 23:30')
              expect(@table.next_period(next_phase: Const.phases.fal_1st)).to eq "2019-05-06 23:30"
            end
          end

          example "秋外交フェイズから秋撤退フェイズへ" do
            time = '2019-05-06 23:30'
            travel_to(time) do
              @table = table
              @table.last_nego_period = Time.zone.parse('2019-05-06 23:30')
              expect(@table.next_period(next_phase: Const.phases.fal_2nd)).to eq "2019-05-07 00:00"
            end
          end

          example "秋撤退フェイズから秋調整フェイズへ：早回し" do
            time = '2019-05-06 23:35'
            travel_to(time) do
              @table = table
              @table.last_nego_period = Time.zone.parse('2019-05-06 23:30')
              expect(@table.next_period(next_phase: Const.phases.fal_3rd)).to eq "2019-05-07 00:05"
            end
          end

          example "秋撤退フェイズから秋調整フェイズへ：定刻" do
            time = '2019-05-07 00:00'
            travel_to(time) do
              @table = table
              @table.last_nego_period = Time.zone.parse('2019-05-06 23:30')
              expect(@table.next_period(next_phase: Const.phases.fal_3rd)).to eq "2019-05-07 00:30"
            end
          end

          example "秋調整フェイズから春外交フェイズへ：早回し" do
            time = '2019-05-06 23:58'
            travel_to(time) do
              @table = table
              @table.last_nego_period = Time.zone.parse('2019-05-06 23:30')
              expect(@table.next_period(next_phase: Const.phases.spr_1st)).to eq "2019-05-07 23:30"
            end
          end
        end
      end

      context "変動制" do
        before :context do
          options = {}
          options[:period_rule] = Const.regulation.period_rule.flexible
          options[:duration] = Const.regulation.duration.standard
          options[:due_date] = "2019-05-04"
          options[:start_time] = "20:00"
          @regulation = Regulation.create(options)
        end

        example "開幕から春外交フェイズへ" do
          time = '2019-05-04 20:00'
          travel_to(time) do
            expect(table.next_period(next_phase: Const.phases.spr_1st)).to eq "2019-05-05 20:00"
          end
        end

        example "春外交フェイズから春撤退フェイズへ：早回し" do
          time = '2019-05-04 23:00'
          travel_to(time) do
            expect(table.next_period(next_phase: Const.phases.spr_2nd)).to eq "2019-05-04 23:30"
          end
        end

        example "春撤退フェイズから秋外交フェイズへ：早回し" do
          time = '2019-05-04 23:20'
          travel_to(time) do
            expect(table.next_period(next_phase: Const.phases.fal_1st)).to eq "2019-05-05 23:20"
          end
        end

        example "秋外交フェイズから秋撤退フェイズへ：早回し" do
          time = '2019-05-06 18:20'
          travel_to(time) do
            expect(table.next_period(next_phase: Const.phases.fal_2nd)).to eq "2019-05-06 18:50"
          end
        end

        example "秋調整フェイズから春外交フェイズへ：早回し" do
          time = '2019-05-06 23:58'
          travel_to(time) do
            expect(table.next_period(next_phase: Const.phases.spr_1st)).to eq "2019-05-07 23:58"
          end
        end
      end
    end

    context "短期卓" do
      context "固定制" do
        context "処理フェイズが日付を跨がない場合" do
          before :context do
            options = {}
            options[:period_rule] = Const.regulation.period_rule.fixed
            options[:duration] = Const.regulation.duration.short
            options[:due_date] = "2019-05-04"
            options[:start_time] = "20:00"
            @regulation = Regulation.create(options)
          end

          example "開幕から春外交フェイズへ" do
            time = '2019-05-04 20:00'
            travel_to(time) do
              @table = table
              @table.last_nego_period = Time.zone.parse('2019-05-04 20:00')
              expect(@table.next_period(next_phase: Const.phases.spr_1st)).to eq "2019-05-04 21:00"
            end
          end

          example "春外交フェイズから春撤退フェイズへ" do
            time = '2019-05-04 21:00'
            travel_to(time) do
              @table = table
              @table.last_nego_period = Time.zone.parse('2019-05-04 21:00')
              expect(@table.next_period(next_phase: Const.phases.spr_2nd)).to eq "2019-05-04 21:15"
            end
          end

          example "春撤退フェイズから秋外交フェイズへ：早回し" do
            time = '2019-05-04 21:07'
            travel_to(time) do
              @table = table
              @table.last_nego_period = Time.zone.parse('2019-05-04 21:00')
              expect(@table.next_period(next_phase: Const.phases.fal_1st)).to eq "2019-05-04 22:00"
            end
          end

          example "春撤退フェイズから秋外交フェイズへ：定刻" do
            time = '2019-05-04 21:15'
            travel_to(time) do
              @table = table
              @table.last_nego_period = Time.zone.parse('2019-05-04 21:00')
              expect(@table.next_period(next_phase: Const.phases.fal_1st)).to eq "2019-05-04 22:00"
            end
          end

          example "秋外交フェイズから秋撤退フェイズへ" do
            travel_to('2019-05-04 22:00') do
              @table = table
              @table.last_nego_period = Time.zone.parse('2019-05-04 22:00')
              expect(@table.next_period(next_phase: Const.phases.fal_2nd)).to eq "2019-05-04 22:15"
            end
          end

          example "秋撤退フェイズから秋調整フェイズへ：早回し" do
            travel_to('2019-05-04 22:12') do
              @table = table
              @table.last_nego_period = Time.zone.parse('2019-05-04 22:00')
              expect(@table.next_period(next_phase: Const.phases.fal_3rd)).to eq "2019-05-04 22:27"
            end
          end

          example "秋撤退フェイズから秋調整フェイズへ：定刻" do
            travel_to('2019-05-04 22:15') do
              @table = table
              @table.last_nego_period = Time.zone.parse('2019-05-04 22:00')
              expect(@table.next_period(next_phase: Const.phases.fal_3rd)).to eq "2019-05-04 22:30"
            end
          end

          example "秋調整フェイズから春外交フェイズへ：早回し" do
            travel_to('2019-05-04 22:29') do
              @table = table
              @table.last_nego_period = Time.zone.parse('2019-05-04 22:00')
              expect(@table.next_period(next_phase: Const.phases.spr_1st)).to eq "2019-05-04 23:00"
            end
          end

          example "秋調整フェイズから春外交フェイズへ：撤退調整のいずれも定刻更新" do
            travel_to('2019-05-04 22:30') do
              @table = table
              @table.last_nego_period = Time.zone.parse('2019-05-04 22:00')
              expect(@table.next_period(next_phase: Const.phases.spr_1st)).to eq "2019-05-04 23:00"
            end
          end
        end

        context "処理フェイズが日付を跨ぐ場合" do
          before :context do
            options = {}
            options[:period_rule] = Const.regulation.period_rule.fixed
            options[:duration] = Const.regulation.duration.short
            options[:due_date] = "2019-05-04"
            options[:start_time] = "22:50"
            @regulation = Regulation.create(options)
          end

          example "開幕から春外交フェイズへ" do
            time = '2019-05-04 22:50'
            travel_to(time) do
              @table = table
              @table.last_nego_period = Time.zone.parse('2019-05-04 22:50')
              expect(@table.next_period(next_phase: Const.phases.spr_1st)).to eq "2019-05-04 23:50"
            end
          end

          example "春外交フェイズから春撤退フェイズへ" do
            time = '2019-05-04 23:50'
            travel_to(time) do
              @table = table
              @table.last_nego_period = Time.zone.parse('2019-05-04 23:50')
              expect(@table.next_period(next_phase: Const.phases.spr_2nd)).to eq "2019-05-05 00:05"
            end
          end

          example "春撤退フェイズから秋外交フェイズへ：早回し" do
            time = '2019-05-04 23:58'
            travel_to(time) do
              @table = table
              @table.last_nego_period = Time.zone.parse('2019-05-04 23:50')
              expect(@table.next_period(next_phase: Const.phases.fal_1st)).to eq "2019-05-05 00:50"
            end
          end

          example "春撤退フェイズから秋外交フェイズへ：定刻" do
            time = '2019-05-05 00:05'
            travel_to(time) do
              @table = table
              @table.last_nego_period = Time.zone.parse('2019-05-04 23:50')
              expect(@table.next_period(next_phase: Const.phases.fal_1st)).to eq "2019-05-05 00:50"
            end
          end

          example "秋外交フェイズから秋撤退フェイズへ" do
            time = '2019-05-05 00:50'
            travel_to(time) do
              @table = table
              @table.last_nego_period = Time.zone.parse('2019-05-05 00:50')
              expect(@table.next_period(next_phase: Const.phases.fal_2nd)).to eq "2019-05-05 01:05"
            end
          end

          example "秋撤退フェイズから秋調整フェイズへ：早回し" do
            time = '2019-05-05 01:02'
            travel_to(time) do
              @table = table
              @table.last_nego_period = Time.zone.parse('2019-05-05 00:50')
              expect(@table.next_period(next_phase: Const.phases.fal_3rd)).to eq "2019-05-05 01:17"
            end
          end

          example "秋撤退フェイズから秋調整フェイズへ：定刻" do
            time = '2019-05-05 01:05'
            travel_to(time) do
              @table = table
              @table.last_nego_period = Time.zone.parse('2019-05-05 00:50')
              expect(@table.next_period(next_phase: Const.phases.fal_3rd)).to eq "2019-05-05 01:20"
            end
          end

          example "秋調整フェイズから春外交フェイズへ：早回し" do
            time = '2019-05-05 01:07'
            travel_to(time) do
              @table = table
              @table.last_nego_period = Time.zone.parse('2019-05-05 00:50')
              expect(@table.next_period(next_phase: Const.phases.spr_1st)).to eq "2019-05-05 01:50"
            end
          end

          example "秋調整フェイズから春外交フェイズへ：撤退調整のいずれも定刻更新" do
            time = '2019-05-05 01:20'
            travel_to(time) do
              @table = table
              @table.last_nego_period = Time.zone.parse('2019-05-05 00:50')
              expect(@table.next_period(next_phase: Const.phases.spr_1st)).to eq "2019-05-05 01:50"
            end
          end
        end
      end

      context "変動制" do
        before :context do
          options = {}
          options[:period_rule] = Const.regulation.period_rule.flexible
          options[:duration] = Const.regulation.duration.short
          options[:due_date] = "2019-05-04"
          options[:start_time] = "20:00"
          @regulation = Regulation.create(options)
        end

        example "開幕から春外交フェイズへ" do
          time = '2019-05-04 20:00'
          travel_to(time) do
            expect(table.next_period(next_phase: Const.phases.spr_1st)).to eq "2019-05-04 21:00"
          end
        end

        example "春外交フェイズから春撤退フェイズへ：早回し" do
          time = '2019-05-04 20:40'
          travel_to(time) do
            expect(table.next_period(next_phase: Const.phases.spr_2nd)).to eq "2019-05-04 20:55"
          end
        end

        example "春撤退フェイズから秋外交フェイズへ：早回し" do
          time = '2019-05-04 20:52'
          travel_to(time) do
            expect(table.next_period(next_phase: Const.phases.fal_1st)).to eq "2019-05-04 21:52"
          end
        end

        example "秋外交フェイズから秋撤退フェイズへ：早回し" do
          time = '2019-05-04 21:50'
          travel_to(time) do
            expect(table.next_period(next_phase: Const.phases.fal_2nd)).to eq "2019-05-04 22:05"
          end
        end

        example "秋調整フェイズから春外交フェイズへ：早回し" do
          time = '2019-05-04 21:59'
          travel_to(time) do
            expect(table.next_period(next_phase: Const.phases.spr_1st)).to eq "2019-05-04 22:59"
          end
        end
      end
    end
  end
end
