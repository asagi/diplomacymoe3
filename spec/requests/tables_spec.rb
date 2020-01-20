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
  describe "POST /tables" do
    context "娘/固定/標準/2020-01-09/1:00/鍵なし/おまかせ" do
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
  "desired_power": ""
}
        JSON
        travel_to("2020-01-08 06:50") do
          post tables_path, params: params_json, headers: headers
        end
      end

      example "API が正常に終了する" do
        expect(response).to be_successful
      end

      example "201 が返ってくる" do
        expect(response.status).to eq 201
      end

      example "Location ヘッダが設定されている" do
        expect(response.headers["Location"]).not_to be_nil
      end

      example "レスポンスに ID が含まれている" do
        json = JSON.parse(response.body)
        expect(json["id"]).to be > 0
      end
    end
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
end
