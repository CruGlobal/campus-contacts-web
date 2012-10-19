require 'test_helper'

class GroupMembershipsControllerTest < ActionController::TestCase

  context "Assigning people to groups" do
    setup do
      @person1 = Factory(:person)
      @person2 = Factory(:person)
      @person3 = Factory(:person)
      @person4 = Factory(:person)
      @user = Factory(:user_with_auxs)
      @org = Factory(:organization)
      @group = Factory(:group, organization: @org)
      request.session[:current_organization_id] = @org.id 
    end

    context "and user has permissions" do
      setup do
        @org.add_admin(@user.person)
        sign_in @user
      end

      should "properly assign a single user to a group" do
        xhr :post, :create, { :group_id => @group.id, :person_id => @person1.id.to_s, :role => "member", :from_add_member_screen => "true" }
        assert_equal(assigns(:group), @group)
        assert_equal(assigns(:persons), @person1)
        assert_not_nil(assigns(:persons))
        assert_not_nil(assigns(:group_membership))
        assert(assigns(:group).members.include? @person1)

        assert_template('group_memberships/create')
        assert_response(:success)
      end

      should "properly assign multiple users to a group" do
        person_ids = "#{@person1.id},#{@person2.id},#{@person3.id},#{@person4.id},"
        xhr :post, :create, { :group_id => @group.id, :person_id => person_ids, :role => "member" }

        assert_equal(assigns(:group), @group)
        assert_not_nil(assigns(:persons))
        assert_equal(4, assigns(:persons).count)
        assert(assigns(:group).members.include? @person1)
        assert(assigns(:group).members.include? @person2)
        assert(assigns(:group).members.include? @person3)
        assert(assigns(:group).members.include? @person4)

        assert_template('group_memberships/create')
        assert_response(:success)
      end
    end

    context "user has no permissions" do
      setup do
        user2 = Factory(:user_with_auxs)
        user3 = Factory(:user_with_auxs)
        @org.add_leader(@user.person, user2.person)
        @org.add_involved(user3.person)
        sign_in user3
      end

      should "fail to assign a single user to a group" do
        xhr :post, :create, { :group_id => @group.id, :person_id => @person1.id.to_s, :role => "member", :from_add_member_screen => "true" }
        assert_template('group_memberships/failed')
      end

      should "fail to assign multiple users to a group" do
        person_ids = "#{@person1.id},#{@person2.id},#{@person3.id},#{@person4.id},"
        xhr :post, :create, { :group_id => @group.id, :person_id => person_ids, :role => "member" }

        assert_template('group_memberships/failed')
      end
    end
  end

  context "search" do
    setup do
      @user, @org = admin_user_login_with_org
      @group = Factory(:group, organization: @org)

      @p1 = Factory(:person, first_name: "Tony", last_name: "Stark")
      @p2 = Factory(:person, first_name: "Tony", last_name: "Banner")
      @p3 = Factory(:person, first_name: "Tony", last_name: "Banner")
      @p1.email_addresses.create(email: 'p1@example.com')
      @p2.email_addresses.create(email: 'p2@example.com')
      @org.add_contact(@p1)
      @org.add_contact(@p2)
      @org.add_contact(@p3)
    end

    should "search when show all is false" do
      xhr :get, :search, { :name => "Tony", :role => "member", :group_id => @group.id }
      assert_not_nil assigns(:people)
      assert_not_nil assigns(:total)
      assert_equal 3, assigns(:total)
    end

    should "search when show all is true" do
      xhr :get, :search, { :name => "Tony", :show_all => true, :role => "member", :group_id => @group.id }
      assert_not_nil assigns(:people)
      assert_not_nil assigns(:total)
      assert_equal assigns(:total), assigns(:people).length
    end

    should "render nothing when no param is found" do
      xhr :get, :search
      assert_equal " ", response.body
    end
  end

  test "destroy" do
    user, org = admin_user_login_with_org
    group = Factory(:group, organization: org)
    person = Factory(:person)
    request.session[:current_organization_id] = org.id 

    xhr :post, :create, { :group_id => group.id, :person_id => person.id, :role => "member", :from_add_member_screen => "true" }
    assert_response :success
    assert_equal 1, GroupMembership.count

    gm = GroupMembership.last
    xhr :post, :destroy, { :id => gm.id, :group_id => group.id }
    assert_not_nil assigns(:group)
    assert_not_nil assigns(:group_membership)
    assert_equal 0, GroupMembership.count
  end
end
