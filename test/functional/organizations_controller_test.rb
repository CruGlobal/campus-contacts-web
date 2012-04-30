require 'test_helper'

class OrganizationsControllerTest < ActionController::TestCase
  context "Creating organizations" do
    setup do
      @user = Factory(:user_with_auxs)  #user with a person object
      sign_in @user
      @org_parent = Factory(:organization)
      @org_parent.add_admin(@user.person)
      @org_child = Factory(:organization, :name => "neilmarion", :parent => @org_parent)
    end

    should "create a child org if it's name is unique, otherwise dont create a child org" do
      xhr :post, :create, {:organization => {:parent_id => @org_parent.id, :name => "neilmarion", :terminology => "Organization", :show_sub_orgs => "1"}}
      assert_equal 1, @org_parent.children.count
      
      xhr :post, :create, {:organization => {:parent_id => @org_parent.id, :name => "notneilmarion", :terminology => "Organization", :show_sub_orgs => "1"}}
      assert_equal 2, @org_parent.children.count
      assert @org_parent.children.collect {|c| c.name }.include? "notneilmarion"
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
  setup do
    @user, @org = admin_user_login_with_org
  end
  
  should "get index" do
    get :index
    assert_response :success
  end
  
  should "get show" do
    xhr :get, :show, { :id => @request.session[:current_organization_id] }
    assert_not_nil assigns(:organization)
  end
  
  should "get edit" do
    get :edit, { :id => @request.session[:current_organization_id] }
    assert_not_nil assigns(:organization)
  end
  
  should "get new" do
    get :new
    assert_not_nil assigns(:organization)
    assert_template 'layouts/splash'
  end
  
  should "get thanks" do
    get :thanks
    assert_template 'layouts/splash'
  end
  
  should "not save when bad params" do
    post :signup, organization: { :name => "wat" }
    assert_template 'layouts/splash'
  end
  
  should "redirect on save with good parameters" do
    post :signup, organization: { :name => "wat", :terminology => "wat" }
    assert_response :redirect
  end
  
  should "get organizations when searching" do
    org1 = Factory(:organization, parent: @org, name: "Test2")
    org2 = Factory(:organization, parent: @org, name: "Test1")
    
    xhr :get, :search, { :q => "Test" }
    assert_not_nil assigns(:organizations)
    assert_not_nil assigns(:total)
    
    assert assigns(:organizations).include? org1
    assert assigns(:organizations).include? org2
  end
  
  should "create org" do
    xhr :post, :create, organization: { :name => "Wat", :terminology => "Wat", :parent_id => @org.id }
    assert_not_nil assigns(:parent)
    assert_not_nil assigns(:organization)
  end
end
