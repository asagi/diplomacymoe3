require "rails_helper"

RSpec.describe "tables", type: :request do
  describe "GET /tables" do
    before :context do
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
    before :context do
      @master = User.find_or_create_by(uid: ENV["MASTER_USER_01"], admin: true)
      @user = User.find_or_create_by(uid: "12345", token: "aaa")
      headers = {}
      headers[:HTTP_AUTHORIZATION] = "Bearer %s" % [@user.token]
      headers[:CONTENT_TYPE] = "application/json"
      headers[:ACCEPT] = "application/json"
      params = {}
      params[:regulation] = {}
      params[:regulation][:face_type] = Const.regulation.face_type.girl
      params[:regulation][:period_rule] = Const.regulation.period_rule.fixed
      params[:regulation][:duration] = Const.regulation.duration.standard
      params[:regulation][:keyword] = ""
      params[:regulation][:due_date] = "2019-12-24"
      params[:regulation][:start_time] = "07:00"
      puts params.to_json      
      post tables_path, params: params.to_json, headers: headers
      @json = JSON.parse(response.body)
    end

    example "200 が返ってくる" do
      puts @json.to_json
      expect(response).to be_successful
      expect(response.status).to eq 200
    end
  end
end
