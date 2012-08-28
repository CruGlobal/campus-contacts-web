require 'test_helper'

class OrganizationMembershipsControllerTest < ActionController::TestCase
  setup do
    @user, @org = admin_user_login_with_org
  end
  
  context "index" do
    should "get index" do
      get :index
      assert_template "organization_memberships/index"
    end
  end
  
  context "show" do
    should "get show" do
      get :show, { :id => @user.person.organization_memberships.first.id }
      assert_template "organization_memberships/show"
    end
  end
  
  context "edit" do
    should "get edit" do
      get :edit, { :id => @user.person.organization_memberships.first.id }
      assert_template "organization_memberships/edit"
    end
  end
  
  context "create" do
    setup do
      @new_org = Factory(:organization)
    end
  
    should "create" do
      @request.session[:return_to] = '/'
      assert_difference "OrganizationMembership.count", 1 do
        post :create, { :organization_id => @new_org.id }
      end
    end
    
    should "not create" do
      assert_no_difference "OrganizationMembership.count" do
        post :create, { :organization_id => nil }
      end
    end
  end
  
  context "update" do
    should "update" do
      put :update, { :id => @user.person.organization_memberships.first.id }
      assert_redirected_to organization_membership_path(@user.person.organization_memberships.first.id)
    end
    
    should "not update" do
      put :update, { :id => @user.person.organization_memberships.first.id, :organization_membership => { :person_id => nil } }
      assert_template "organization_memberships/edit"
    end
  end
  
  context "destroy" do
    should "destroy" do
      post :destroy, { :id => @user.person.organization_memberships.first.id }
      assert_redirected_to person_organization_memberships_path(@user.person)
    end
  end
  
  context "set current" do
    setup do
      @new_org = Factory(:organization, :parent => @org)
      Factory(:organization_membership, person: @user.person, organization: @new_org)
    end
  
    should "set_current" do
      get :set_current, { :id => @new_org.id }
      assert_redirected_to contacts_path
      assert_equal @request.session[:current_organization_id], @new_org.id.to_s
    end
  end
  
  context "set primary" do
    setup do
      @new_org = Factory(:organization, :parent => @org)
      Factory(:organization_membership, person: @user.person, organization: @new_org)
    end
  
    should "set_primary" do
      get :set_primary, { :id => @new_org.id }
      assert_redirected_to contacts_path
      assert_equal @request.session[:current_organization_id], @new_org.id.to_s
    end
  end

  # setup do
  #   @organization_membership = organization_memberships(:one)
  # end
  # 
  # test "should get index" do
  #   get :index
  #   assert_response :success
  #   assert_not_nil assigns(:organization_memberships)
  # end
  # 
  # test "should get new" do
  #   get :new
  #   assert_response :success
  # end
  # 
  # test "should create organization_membership" do
  #   assert_difference('OrganizationMembership.count') do
  #     post :create, organization_membership: @organization_membership.attributes
  #   end
  # 
  #   assert_redirected_to organization_membership_path(assigns(:organization_membership))
  # end
  # 
  # test "should show organization_membership" do
  #   get :show, id: @organization_membership.to_param
  #   assert_response :success
  # end
  # 
  # test "should get edit" do
  #   get :edit, id: @organization_membership.to_param
  #   assert_response :success
  # end
  # 
  # test "should update organization_membership" do
  #   put :update, id: @organization_membership.to_param, organization_membership: @organization_membership.attributes
  #   assert_redirected_to organization_membership_path(assigns(:organization_membership))
  # end
  # 
  # test "should destroy organization_membership" do
  #   assert_difference('OrganizationMembership.count', -1) do
  #     delete :destroy, id: @organization_membership.to_param
  #   end
  # 
  #   assert_redirected_to organization_memberships_path
  # end
end
