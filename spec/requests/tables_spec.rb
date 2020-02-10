# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'tables', type: :request do
  before :example do
    create(:master)
  end

  let(:user) { create(:user) }
  let(:headers) do
    headers = {}
    headers[:HTTP_AUTHORIZATION] = format('Bearer %<token>s', token: user.token)
    headers[:CONTENT_TYPE] = 'application/json'
    headers
  end
  describe 'POST /api/tables' do
    context '娘/固定/標準/2020-01-09/1:00/鍵なし/おまかせ' do
      before :example do
        @params_json = <<~'JSON'
          {
            "face_type": "girl",
            "period_rule": "fixed",
            "duration": "standard",
            "juggling": "allow",
            "private": false,
            "keyword": "",
            "due_date": "2020-01-09",
            "start_time": "1:00",
            "desired_power": ""
          }
        JSON
        travel_to('2020-01-08 06:50') do
          post tables_path, params: @params_json, headers: headers
        end
      end

      example 'API が正常に終了する' do
        expect(response).to be_successful
      end

      example '201 が返ってくる' do
        expect(response.status).to eq 201
      end

      example 'Location ヘッダが設定されている' do
        json = JSON.parse(response.body)
        expect(response.headers['Location']).to eq table_path(json['id'])
      end

      example 'レスポンスに ID が含まれている' do
        json = JSON.parse(response.body)
        expect(json['id']).to be_positive
        # get table_path(json['id'])
        # puts response.body
      end

      example '多重卓立て禁止' do
        travel_to('2020-01-08 06:50') do
          post tables_path, params: @params_json, headers: headers
          # puts response.body
          expect(response.status).to eq 422
        end
      end
    end
  end

  describe 'POST /api/tables' do
    context '旗/変動/短期/2020-01-09/1:00/鍵あり/英' do
      before :example do
        params_json = <<~'JSON'
          {
            "face_type": "flag",
            "period_rule": "flexible",
            "duration": "short",
            "juggling": "disallow",
            "private": true,
            "keyword": "aaa",
            "due_date": "2020-01-09",
            "start_time": "1:00",
            "desired_power": "e"
          }
        JSON
        travel_to('2020-01-08 06:50') do
          post tables_path, params: params_json, headers: headers
        end
      end

      example 'API が正常に終了する' do
        expect(response).to be_successful
      end

      example '201 が返ってくる' do
        expect(response.status).to eq 201
      end

      example 'レスポンスに ID が含まれている' do
        json = JSON.parse(response.body)
        expect(json['id']).to be_positive
      end

      example '生成された卓の face_type が旗' do
        json = JSON.parse(response.body)
        expect(Table.find(json['id']).regulation.face_type).to eq 'flag'
      end

      example '生成された卓の period_rule が変動' do
        json = JSON.parse(response.body)
        expect(Table.find(json['id']).regulation.period_rule).to eq 'flexible'
      end

      example '生成された卓の duration が短期' do
        json = JSON.parse(response.body)
        expect(Table.find(json['id']).regulation.duration).to eq 'short'
      end

      example '生成された卓の juggling が不許可' do
        json = JSON.parse(response.body)
        expect(Table.find(json['id']).regulation.juggling).to eq 'disallow'
      end

      example '生成された卓の private が true' do
        json = JSON.parse(response.body)
        expect(Table.find(json['id']).regulation.private).to be true
      end

      example '生成された卓の keyword が aaa' do
        json = JSON.parse(response.body)
        expect(Table.find(json['id']).regulation.keyword).to eq 'aaa'
      end

      example '生成された卓の卓主の希望国が英' do
        json = JSON.parse(response.body)
        expect(Table.find(json['id']).players.first.desired_power).to eq 'e'
      end
    end
  end

  describe 'GET /api/tables' do
    context '1 件もない場合' do
      before :example do
        get tables_path
        @json = JSON.parse(response.body)
      end

      example 'API が正常に終了する' do
        expect(response).to be_successful
      end

      example '200 が返ってくる' do
        expect(response.status).to eq 200
      end

      example '登録されている卓数が 0 件であること' do
        expect(@json.size).to eq 0
      end
    end

    context '5 件登録後' do
      before :example do
        5.times { create(:table).save }

        get tables_path
        @json = JSON.parse(response.body)
      end

      example 'API が正常に終了する' do
        expect(response).to be_successful
      end

      example '200 が返ってくる' do
        expect(response.status).to eq 200
      end

      example '登録されている卓数が 5 件であること' do
        expect(@json.size).to eq 5
      end
    end
  end

  describe 'GET /api/numbered-tables/:num' do
    context '卓番号 1 を取得' do
      before :example do
        @table = create(:table)
        @table.number = 1
        @table.save!

        get numbered_table_path(@table.number)
        @json = JSON.parse(response.body)
      end

      example 'API が正常に終了する' do
        expect(response).to be_successful
      end

      example '200 が返ってくる' do
        expect(response.status).to eq 200
      end

      example '取得した卓の卓番号が 1 であること' do
        expect(@json['number']).to eq @table.number
      end
    end
  end
end
