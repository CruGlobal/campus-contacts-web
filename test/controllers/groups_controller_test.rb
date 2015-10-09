require 'test_helper'

class GroupsControllerTest < ActionController::TestCase
  test 'should have permission to see a group in a sub-org' do
    set_up_group_at_sub_org
    get :show, id: @group.id
    assert_response :success
    assert_template :show
  end

  test 'should be able to create a group in a sub-org' do
    set_up_group_at_sub_org
    get :new
    assert_response :success
    assert_template :new
  end

  context 'Editing a group' do
    should 'edit' do
      @user, @org = admin_user_login_with_org
      @group = FactoryGirl.create(:group, organization: @org)
      get :edit, id: @group.id
    end

    should 'not edit when group is not existing' do
      @user, @org = admin_user_login_with_org
      get :edit, id: 100
    end
  end

  context 'show group details' do
    setup do
      user = FactoryGirl.create(:user_with_auxs)
      sign_in user
      user2 = FactoryGirl.create(:user_with_auxs)
      org = FactoryGirl.create(:organization)
      FactoryGirl.create(:email_address, email: 'user@email.com', person: user.person)
      FactoryGirl.create(:email_address, email: 'user2@email.com', person: user2.person)
      user.person.reload
      user2.person.reload
      org.add_leader(user.person, user2.person)
      request.session[:current_organization_id] = org.id
      @group = FactoryGirl.create(:group, organization: org)

      @contact1 = FactoryGirl.create(:person, first_name: 'C', last_name: 'C')
      FactoryGirl.create(:organizational_permission, organization: org, person: @contact1, permission: Permission.admin)
      @contact2 = FactoryGirl.create(:person, first_name: 'D', last_name: 'D')
      FactoryGirl.create(:organizational_permission, organization: org, person: @contact2, permission: Permission.no_permissions)
      @contact3 = FactoryGirl.create(:person, first_name: 'E', last_name: 'E')
      FactoryGirl.create(:organizational_permission, organization: org, person: @contact3, permission: Permission.user)

      FactoryGirl.create(:group_membership, group: @group, person: @contact1)
      FactoryGirl.create(:group_membership, group: @group, person: @contact2)
      FactoryGirl.create(:group_membership, group: @group, person: @contact3, role: 'leader')
    end

    should 'get show' do
      get :show, id: @group.id
      assert_response(:success)
    end

    should 'get show with sorting by first_name asc' do
      get :show, search: { meta_sort: 'first_name asc' }, id: @group.id
      assert_response(:success)
      assert_equal assigns(:people).collect(&:id), [@contact1.id, @contact2.id, @contact3.id]
    end

    should 'get show with sorting by first_name desc' do
      get :show, search: { meta_sort: 'first_name desc' }, id: @group.id
      assert_response(:success)
      assert_equal assigns(:people).collect(&:id), [@contact3.id, @contact2.id, @contact1.id]
    end

    should 'get show with sorting by role desc' do
      get :show, search: { meta_sort: 'role desc' }, id: @group.id
      assert_response(:success)
      assert_equal @contact3.id, assigns(:people).last.id
    end

    should 'get show with sorting by role asc' do
      get :show, search: { meta_sort: 'role asc' }, id: @group.id
      assert_response(:success)
      assert_equal assigns(:people).first, @contact3
    end
  end

  context 'on index' do
    setup do
      @user, @org = admin_user_login_with_org

      @label = FactoryGirl.create(:group_label, organization: @user.person.organizations.first)
      @group = FactoryGirl.create(:group, organization: @user.person.organizations.first, name: 'Group1')
      FactoryGirl.create(:group, organization: @org, name: 'Group2')
      FactoryGirl.create(:group, organization: @org, name: 'Group3')
    end

    should 'get index' do
      get :index
      assert_not_nil assigns(:groups)
    end

    should 'get index should be sorted by name as default' do
      get :index
      assert_equal assigns(:groups).collect(&:name), %w(Group1 Group2 Group3)
      assert_response(:success)
    end

    should 'get index should return groups sorted by name asc' do
      get :index, search: { meta_sort: 'name asc' }
      assert_equal assigns(:groups).collect(&:name), %w(Group1 Group2 Group3)
      assert_response(:success)
    end

    should 'get index should return groups sorted by name desc' do
      get :index, search: { meta_sort: 'name desc' }
      assert_equal assigns(:groups).collect(&:name), %w(Group3 Group2 Group1)
      assert_response(:success)
    end
  end

  context 'updating group' do
    setup do
      @user, @org = admin_user_login_with_org
    end

    should 'update group' do
      group = FactoryGirl.create(:group, organization: @org)
      post :update, id: group.id, group: { name: 'WAT' }
      assert_not_nil assigns(:group)
      assert_response :redirect
    end

    should 'not update group' do
      request.env['HTTP_REFERER'] = '/groups/new'
      group = FactoryGirl.create(:group, organization: @org)
      post :update, id: group.id, group: { name: '' }
      assert_response :redirect
    end
  end

  context 'creating group' do
    setup do
      @user, @org = admin_user_login_with_org
    end

    should 'create group' do
      post :create, group: { name: 'Wat', location: 'Philippines', meets: 'weekly', start_time: '21600', end_time: '25200', organization_id: @org.id }
      assert_equal 1, @org.groups.count
      assert_response :redirect
    end

    should 'not create group' do
      assert_no_difference 'Group.count' do
        post :create, group: { name: '', location: 'Philippines', meets: 'weekly', start_time: '21600', end_time: '25200', organization_id: @org.id }
        assert_response :success
      end
    end
  end

  should 'destroy group' do
    @user, @org = admin_user_login_with_org
    @group = FactoryGirl.create(:group, organization: @org)

    @contact1 = FactoryGirl.create(:person, first_name: 'C', last_name: 'C')
    FactoryGirl.create(:organizational_permission, organization: @org, person: @contact1, permission: Permission.no_permissions)
    FactoryGirl.create(:group_membership, group: @group, person: @contact1)

    assert_difference 'Group.count', -1 do
      assert_difference 'GroupMembership.count', -1 do
        post :destroy, id: @group.id
      end
    end
    assert_redirected_to groups_path
  end

  def set_up_group_at_sub_org
    @user = FactoryGirl.create(:user_with_auxs)
    sign_in @user
    org = FactoryGirl.create(:organization)
    org.add_admin(@user.person)
    @sub_org = FactoryGirl.create(:organization, parent: org, show_sub_orgs: false)
    @group = FactoryGirl.create(:group, organization: @sub_org)
    request.session[:current_organization_id] = @sub_org.id
  end
end
