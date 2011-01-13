require 'test_helper'

class CommunityMembershipsControllerTest < ActionController::TestCase
  setup do
    @community_membership = community_memberships(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:community_memberships)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create community_membership" do
    assert_difference('CommunityMembership.count') do
      post :create, :community_membership => @community_membership.attributes
    end

    assert_redirected_to community_membership_path(assigns(:community_membership))
  end

  test "should show community_membership" do
    get :show, :id => @community_membership.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @community_membership.to_param
    assert_response :success
  end

  test "should update community_membership" do
    put :update, :id => @community_membership.to_param, :community_membership => @community_membership.attributes
    assert_redirected_to community_membership_path(assigns(:community_membership))
  end

  test "should destroy community_membership" do
    assert_difference('CommunityMembership.count', -1) do
      delete :destroy, :id => @community_membership.to_param
    end

    assert_redirected_to community_memberships_path
  end
end
