require "rails_helper"

RSpec.describe "tables", type: :request do
  before :example do
    create(:master)
  end

  let(:user) { create(:user) }

  describe "GET /tables" do
    before :example do
      get tables_path
      @json = JSON.parse(response.body)
    end

    example "200 が返ってくる" do
      expect(response).to be_successful
      expect(response.status).to eq 200
      expect(@json.size).to eq 0
    end
  end

  describe "POST /tables" do
    before :example do
      headers = {}
      headers[:HTTP_AUTHORIZATION] = "Bearer %s" % [user.token]
      headers[:CONTENT_TYPE] = "application/json"
      params = {}
      params[:face_type] = Const.regulation.face_type.girl
      params[:period_rule] = Const.regulation.period_rule.fixed
      params[:duration] = Const.regulation.duration.standard
      params[:keyword] = ""
      params[:due_date] = "2019-12-24"
      params[:start_time] = "07:00"
      post tables_path, params: params.to_json, headers: headers
      @json = JSON.parse(response.body)
    end

    example "200 が返ってくる" do
      expect(response).to be_successful
      expect(response.status).to eq 200
    end
  end
end
