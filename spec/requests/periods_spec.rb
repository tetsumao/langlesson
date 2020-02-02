require 'rails_helper'

RSpec.describe "Periods", type: :request do
  describe "GET /periods" do
    it "works! (now write some real specs)" do
      get periods_path
      expect(response).to have_http_status(200)
    end
  end
end
