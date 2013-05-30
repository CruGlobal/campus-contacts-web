require 'test_helper'

class GroupsControllerTest < ActionController::TestCase
  test "should have permission to see a group in a sub-org" do
    set_up_group_at_sub_org
    get :show, id: @group.id
    assert_response :success
    assert_template :show
  end

  test "should be able to create a group in a sub-org" do
    set_up_group_at_sub_org
    get :new
    assert_response :success
    assert_template :new
  end



  context "Editing a group" do
    should "edit" do
      @user, @org = admin_user_login_with_org
      @group = Factory(:group, organization: @org)
      get :edit, { :id => @group.id }
    end

    should "not edit when group is not existing" do
      @user, @org = admin_user_login_with_org
      get :edit, { :id => 100 }
    end
  end

  context "show group details" do
    setup do
      user = Factory(:user_with_auxs)
      sign_in user
      user2 = Factory(:user_with_auxs)
      org = Factory(:organization)
      org.add_leader(user.person, user2.person)
      request.session[:current_organization_id] = org.id
      @group = Factory(:group, organization: org)

      @contact1 = Factory(:person, first_name: "C", last_name: "C")
      Factory(:organizational_role, organization: org, person: @contact1, role: Role.admin)
      @contact2 = Factory(:person, first_name: "D", last_name: "D")
      Factory(:organizational_role, organization: org, person: @contact2, role: Role.contact)
      @contact3 = Factory(:person, first_name: "E", last_name: "E")
      Factory(:organizational_role, organization: org, person: @contact3, role: Role.missionhub_user)

      Factory(:group_membership, group: @group, person: @contact1)
      Factory(:group_membership, group: @group, person: @contact2)
      Factory(:group_membership, group: @group, person: @contact3, role: "leader")
    end

    should "get show" do
      get :show, :id => @group.id
      assert_response(:success)
    end

    should "get show with sorting by first_name asc" do
      get :show, { :search =>{:meta_sort => "first_name asc"}, :id => @group.id}
      assert_response(:success)
      assert_equal assigns(:people).collect{|x| x.id}, [@contact1.id, @contact2.id, @contact3.id]
    end

    should "get show with sorting by first_name desc" do
      get :show, { :search =>{:meta_sort => "first_name desc"}, :id => @group.id}
      assert_response(:success)
      assert_equal assigns(:people).collect{|x| x.id}, [@contact3.id, @contact2.id, @contact1.id]
    end

    should "get show with sorting by role desc" do
      get :show, { :search =>{:meta_sort => "role desc"}, :id => @group.id}
      assert_response(:success)
      assert_equal @contact3.id, assigns(:people).last.id
    end

    should "get show with sorting by role asc" do
      get :show, { :search =>{:meta_sort => "role asc"}, :id => @group.id}
      assert_response(:success)
      assert_equal assigns(:people).first, @contact3
    end
  end

  context "on index" do
    setup do
      @user, @org = admin_user_login_with_org

      @label = Factory(:group_label, organization: @user.person.organizations.first)
      @group = Factory(:group, organization: @user.person.organizations.first, name: 'Group1')
      Factory(:group, organization: @org, name: 'Group2')
      Factory(:group, organization: @org, name: 'Group3')
    end

    should "get index" do
      get :index
      assert_not_nil assigns(:groups)
    end

    should "get index should be sorted by name as default" do
      get :index
      assert_equal assigns(:groups).collect(&:name), ['Group1','Group2','Group3']
      assert_response(:success)
    end

    should "get index should return groups sorted by name asc" do
      get :index, {:search =>{:meta_sort => "name asc"}}
      assert_equal assigns(:groups).collect(&:name), ['Group1','Group2','Group3']
      assert_response(:success)
    end

    should "get index should return groups sorted by name desc" do
      get :index, {:search =>{:meta_sort => "name desc"}}
      assert_equal assigns(:groups).collect(&:name), ['Group3','Group2','Group1']
      assert_response(:success)
    end

    should "get index with through labels with groups" do
      Factory(:group_labeling, group: @group, group_label: @label)
      get :index, { :label => @label.id }
      assert_equal assigns(:groups).collect(&:id), [@group.id]
    end

    should "not get index when label id is not existing" do
      get :index, { :label => @label.id + 1}
      assert_not_nil assigns(:groups)
    end
  end

  context "updating group" do

    setup do
      @user, @org = admin_user_login_with_org
    end

    should "update group" do
      group = Factory(:group, organization: @org)
      post :update, { :id => group.id, :group => { :name => "WAT" } }
      assert_not_nil assigns(:group)
      assert_response :redirect
    end

    should "not update group" do
      request.env["HTTP_REFERER"] = "/groups/new"
      group = Factory(:group, organization: @org)
      post :update, { :id => group.id, :group => { :name => "" } }
      assert_response :redirect
    end

  end

  context "creating group" do

    setup do
      @user, @org = admin_user_login_with_org
    end

    should "create group" do
      post :create, group: { :name => "Wat", :location => "Philippines", :meets => "weekly", :start_time => "21600", :end_time => "25200", :organization_id => @org.id }
      assert_equal 1, @org.groups.count
      assert_response :redirect
    end

    should "not create group" do
      assert_no_difference "Group.count" do
        post :create, group: { :name => "", :location => "Philippines", :meets => "weekly", :start_time => "21600", :end_time => "25200", :organization_id => @org.id }
        assert_response :success
      end
    end

  end

  should "destroy group" do
    @user, @org = admin_user_login_with_org
    @group = Factory(:group, organization: @org)

    @contact1 = Factory(:person, first_name: "C", last_name: "C")
    Factory(:organizational_role, organization: @org, person: @contact1, role: Role.contact)
    Factory(:group_membership, group: @group, person: @contact1)

    assert_difference "Group.count", -1 do
      assert_difference "GroupMembership.count", -1 do
        post :destroy, { :id => @group.id}
      end
    end
    assert_redirected_to groups_path
  end

  def set_up_group_at_sub_org
    @user = Factory(:user_with_auxs)
    sign_in @user
    org = Factory(:organization)
    org.add_admin(@user.person)
    @sub_org = Factory(:organization, parent: org, show_sub_orgs: false)
    @group = Factory(:group, organization: @sub_org)
    request.session[:current_organization_id] = @sub_org.id
  end

end
