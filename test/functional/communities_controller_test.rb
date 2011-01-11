require 'test_helper'

class CommunitiesControllerTest < ActionController::TestCase
  setup do
    @community = communities(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:communities)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create community" do
    assert_difference('Community.count') do
      post :create, :community => @community.attributes
    end

    assert_redirected_to community_path(assigns(:community))
  end

  test "should show community" do
    get :show, :id => @community.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @community.to_param
    assert_response :success
  end

  test "should update community" do
    put :update, :id => @community.to_param, :community => @community.attributes
    assert_redirected_to community_path(assigns(:community))
  end

  test "should destroy community" do
    assert_difference('Community.count', -1) do
      delete :destroy, :id => @community.to_param
    end

    assert_redirected_to communities_path
  end
end
