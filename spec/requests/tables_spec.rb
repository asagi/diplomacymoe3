require "rails_helper"

RSpec.describe "tables", type: :request do
  describe "GET /tables" do
    before :context do
      get tables_path
      @json = JSON.parse(response.body)
    end

    example "200 が返ってくる" do
      expect(response).to be_success
      expect(response.status).to eq 200
    end
  end
end
