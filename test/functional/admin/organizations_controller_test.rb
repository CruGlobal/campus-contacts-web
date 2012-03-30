require 'test_helper'

class Admin::OrganizationsControllerTest < ActionController::TestCase
  context "Creating organizations" do
    setup do
      org_parent = Factory(:organization)
      org_child = Factory(:organization, :name => "neilmarion", :parent => org1)
    end

    should "not create organization if it's name is equal to one of its sibling" do
      post :update, {:organization => {:parent_id =>"23", :name => "Bandana", :terminology => "Organization", :show_sub_orgs => "1"}}
      assert_equal Organization.count, 2, "Created organization with the same name as its sibling."
      assert_response :success
    end

  end


  # setup do
  #   @organization = organizations(:one)
  # end
  # 
  # test "should get index" do
  #   get :index
  #   assert_response :success
  #   assert_not_nil assigns(:organizations)
  # end
  # 
  # test "should get new" do
  #   get :new
  #   assert_response :success
  # end
  # 
  # test "should create organization" do
  #   assert_difference('Admin::Organization.count') do
  #     post :create, organization: @organization.attributes
  #   end
  # 
  #   assert_redirected_to admin_organization_path(assigns(:organization))
  # end
  # 
  # test "should show organization" do
  #   get :show, id: @organization.to_param
  #   assert_response :success
  # end
  # 
  # test "should get edit" do
  #   get :edit, id: @organization.to_param
  #   assert_response :success
  # end
  # 
  # test "should update organization" do
  #   put :update, id: @organization.to_param, organization: @organization.attributes
  #   assert_redirected_to admin_organization_path(assigns(:organization))
  # end
  # 
  # test "should destroy organization" do
  #   assert_difference('Admin::Organization.count', -1) do
  #     delete :destroy, id: @organization.to_param
  #   end
  # 
  #   assert_redirected_to organizations_path
  # end
end
