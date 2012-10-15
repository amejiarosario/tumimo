require 'test_helper'

class SignInControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

end
