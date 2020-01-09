require "rails_helper"

RSpec.describe "tables", type: :request do
  before :example do
    create(:master)
  end

  let(:user) { create(:user) }
  let(:headers) do
    headers = {}
    headers[:HTTP_AUTHORIZATION] = "Bearer %s" % [user.token]
    headers[:CONTENT_TYPE] = "application/json"
    headers
  end

  describe "GET /tables" do
    context "1 件もない場合" do
      before :example do
        get tables_path
        @json = JSON.parse(response.body)
      end

      example "API が正常に終了する" do
        expect(response).to be_successful
      end

      example "200 が返ってくる" do
        expect(response.status).to eq 200
      end

      example "登録されている卓数が 0 件であること" do
        expect(@json.size).to eq 0
      end
    end

    context "5 件登録後" do
      before :example do
        (1..5).each { create(:table).save }

        get tables_path
        @json = JSON.parse(response.body)
      end

      example "API が正常に終了する" do
        expect(response).to be_successful
      end

      example "200 が返ってくる" do
        expect(response.status).to eq 200
      end

      example "登録されている卓数が 5 件であること" do
        expect(@json.size).to eq 5
      end
    end
  end

  describe "POST /tables" do
    context "娘/固定/標準/2020-01-09/1:00/鍵なし/おまかせ" do
      let (:table) { Table.find(@json["id"]) }
      before :example do
        params_json = <<-'JSON'
  {
    "face_type": "1",
    "period_rule": "1",
    "duration": "2",
    "juggling": "1",
    "private": false,
    "keyword": "",
    "due_date": "2020-01-09",
    "start_time": "1:00",
    "power": ""
  }
        JSON

        post tables_path, params: params_json, headers: headers
        @json = JSON.parse(response.body)
      end

      example "API が正常に終了する" do
        expect(response).to be_successful
      end

      example "200 が返ってくる" do
        expect(response.status).to eq 200
      end

      example "作成された卓の ID が null ではないこと" do
        expect(@json["id"]).not_to be_nil
      end

      example "レスポンスの ID の卓が 存在すること" do
        expect(table).not_to be_nil
      end

      example "作成された卓のフェイスタイプが娘であること" do
        expect(table.face_type).to eq "girl"
      end

      example "作成された卓の更新期限が固定であること" do
        expect(table.period_rule).to eq "fixed"
      end

      example "作成された卓の外交周期が標準であること" do
        expect(table.duration).to eq "standard"
      end

      example "作成された卓の初回更新日時が '2020-01-09 1:00' であること" do
        expect(table.regulation.first_period).to eq "2020-01-09 1:00"
      end
    end
  end
end
