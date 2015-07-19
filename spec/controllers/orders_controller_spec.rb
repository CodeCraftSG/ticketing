require 'rails_helper'

RSpec.describe OrdersController, type: :controller do

  describe "GET #express_checkout" do
    it "returns http success" do
      get :express_checkout
      expect(response).to have_http_status(:success)
    end
  end

end
