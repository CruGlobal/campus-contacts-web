require 'test_helper'

class ProfileControllerTest < ActionController::TestCase
  setup do
    @user, @org = admin_user_login_with_org
    @contact = FactoryGirl.create(:person, first_name: 'Contact', last_name: 'One')
    @org.add_contact(@contact)

    @other_org = FactoryGirl.create(:organization)
    @other_contact = FactoryGirl.create(:person, first_name: 'Contact', last_name: 'One')
    @other_org.add_contact(@other_contact)
  end

  context 'Viewing a profile' do
    should 'show the profile' do
      get :show, id: @contact.id
      assert_response :success
      assert_equal assigns(:person), @contact
    end

    should 'redirect to all contacts when no person found' do
      get :show, id: ''
      assert_redirected_to all_contacts_path
    end

    should 'load the leaders whom person is assigned to' do
      FactoryGirl.create(:contact_assignment, organization: @org, assigned_to: @user.person, person: @contact)
      get :show, id: @contact.id
      assert_not_nil assigns(:assigned_tos), assigns(:assigned_tos).inspect
    end

    context "displaying a person's friends in their profile" do
      setup do
        @person = FactoryGirl.create(:person_with_facebook_data)
        @person1 = FactoryGirl.create(:person, fb_uid: 3_248_973)
        @person2 = FactoryGirl.create(:person, fb_uid: 3_343_484)
        # add them in the org
        @org.add_contact(@person)
        @org.add_contact(@person1)
        @org.add_contact(@person2)
      end

      should 'return the friends who are members of the same org as person' do
        friend1 = Friend.new(@person1.fb_uid, @person1.name, @person)
        friend2 = Friend.new(@person2.fb_uid, @person1.name, @person)

        get :show, id: @person.id
        org_friends = assigns(:friends)
        assert_not_nil(org_friends)
        assert(org_friends.include?(@person1), 'should include person1')
        assert(org_friends.include?(@person2), 'should include person2')
      end
    end

    should 'not show a person from other_org' do
      get :show, id: @other_org.id
      assert_response :redirect
    end

    should 'show a current person even when current org is sub org' do
      @sub_org = FactoryGirl.create(:organization, ancestry: @org.id)
      @request.session[:current_organization_id] = @sub_org.id
      get :show, id: @user.person.id
      assert_response :success
      assert_equal @user.person, assigns(:person)
    end
  end
end
