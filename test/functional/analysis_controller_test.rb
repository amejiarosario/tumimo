require 'test_helper'

class AnalysisControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

end
