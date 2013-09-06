require 'test_helper'

class LeadersControllerTest < ActionController::TestCase
  context "Leader Link is clicked" do
    setup do
      @leader_user = Factory(:user_with_auxs, remember_token: "123456", remember_token_expires_at: Date.today + 10.day)
    end
    should "redirect if incorrect token" do
      get :leader_sign_in, user_id: @leader_user.id, token: "123"
      assert_redirected_to '/users/sign_in'
    end
    should "redirect to login page when no active session" do
      get :leader_sign_in, user_id: @leader_user.id, token: @leader_user.remember_token
      assert_redirected_to '/users/sign_in'
    end
    should "redirect to merge page when there is an active session" do
      @user = Factory(:user_with_auxs)
      sign_in @user
      get :leader_sign_in, user_id: @leader_user.id, token: @leader_user.remember_token
      assert_response :success
      assert_template 'leaders/leader_sign_in'
      assert assigns(:valid_token)
    end
    should "say sorry if the token is expired when visiting the leader_link" do
      @user = Factory(:user_with_auxs)
      sign_in @user
      @leader_user.update_attribute(:remember_token_expires_at, Date.today - 1.day)
      get :leader_sign_in, user_id: @leader_user.id, token: @leader_user.remember_token
      assert_response :success
      assert_template 'leaders/leader_sign_in'
      assert !assigns(:valid_token)
    end
    should "say sorry if the token is expired when visiting the merge_leader_link" do
      @user = Factory(:user_with_auxs)
      sign_in @user
      @leader_user.update_attribute(:remember_token_expires_at, Date.today - 1.day)
      get :merge_leader_accounts, user_id: @leader_user.id, token: @leader_user.remember_token
      assert_response :success
      assert_template 'leaders/leader_sign_in'
      assert !assigns(:valid_token)
    end
    should "destroy session and redirect to login page when do user do not want to merge accounts" do
      @user = Factory(:user_with_auxs)
      sign_in @user
      get :sign_out_and_leader_sign_in, user_id: @leader_user.id, token: @leader_user.remember_token
      assert_nil session[:user_id]
      assert_redirected_to "/l/#{@leader_user.remember_token}/#{@leader_user.id}"
    end
  end
  context "After logging in a person with orgs" do
    setup do
      @user = Factory(:user_with_auxs)  #user with a person object
      sign_in @user
    end

    should "should get search" do
      xhr :get, :search, name: 'Test user'
      assert_response :success, @response.body
      assert_equal(0, assigns(:total))
    end

    should "should get search and show all" do
      xhr :get, :search, name: 'Test user', show_all: 'true'
      assert_response :success, @response.body
      assert_equal(0, assigns(:total))
    end

    should "should render nothing on a blank search" do
      xhr :get, :search, name: '', show_all: 'true'
      assert_response :success, @response.body
      assert_equal(' ', @response.body)
    end

    should "should get new" do
      xhr :get, :new, name: 'Test user'
      assert_response :success
    end

    # The create action gets called directly, and also by #add_person and #update
    should "add a person with a valid email address as a leader" do
      person = Factory(:person)
      person.email = 'good_address@example.com'
      person.user = nil
      person.save(validate: false)
      # In the drect call, we're passing in a person_id that was clicked on
      # If the person is missing a user, a user should be created
      assert_difference('User.count') do
        xhr :post, :create, person_id: person.id
        assert_response :success
        assert_template 'leaders/create'
      end
    end

    should "prompt for email when adding a person without a user or valid email as a leader" do
      person = Factory(:person)
      person.email = 'bad email'
      person.user = nil
      person.save(validate: false)
      assert_no_difference('OrganizationalPermission.count') do
        assert_no_difference('User.count') do
          xhr :post, :create, person_id: person.id
          assert_response :success
        end
      end
      assert_template 'leaders/edit'
    end

    should "add a leader manually (already in db, but not in this org)" do
      user2 = Factory(:user_with_auxs)
      user2.person.update_attribute(:email, 'test@example.com')

      assert_difference('OrganizationalPermission.count') do
        assert_no_difference('User.count') do
          xhr :post, :add_person, person: {first_name: 'John', last_name: 'Doe', email_address: {email: user2.person.email_addresses.first.email}}, notify: '1' #, person_id: user2.person.id
          assert_response :success
        end
      end
    end

    should "add a leader manually (not already in db)" do
      assert_difference('OrganizationalPermission.count') do
        assert_difference('User.count') do
          assert_difference('Person.count') do
            xhr :post, :add_person, person: {first_name: 'John1', last_name: 'Doe', gender: '1', email_address: {email: 'new_user@example.com'}, phone_number: {phone: '444-444-4444'}}, notify: '1'
            assert_response :success
            assert_equal(nil, flash[:error])
            assert_not_nil(assigns(:person).user, "New user didn't get created")
            assert_template 'leaders/create'
          end
        end
      end
    end

    should "require gender, first name, last name and email when adding a leader" do
      xhr :post, :add_person, person: {first_name: '', last_name: '', email_address: {email: ''}, phone_number: {phone: ''}}, notify: '1'
      assert_response :success
      assert_equal("<font color='red'>First Name is required.<br />Last Name is required.<br />Gender is required.<br />Email is required.<br /></font>", flash[:error])
      assert_template 'leaders/new'
    end

    should "validate email when adding a leader" do
      xhr :post, :add_person, person: {first_name: 'John1', last_name: 'Doe', gender: '1', email_address: {email: 'Howie Koffman <howie.kauffman@facultycommons.org>'}, phone_number: {phone: '444-444-4444'}}, notify: '1'
      assert_response :success
      assert_equal("<font color='red'>Email Address isn't valid.<br /></font>", flash[:error])
      assert_template 'leaders/new'
    end

    should "update a person and add them as a leader" do
      person = Factory(:person)
      person.email = 'bad email'
      person.user = nil
      person.save(validate: false)
      assert_difference('OrganizationalPermission.count') do
        assert_difference('User.count') do
          xhr :put, :update, id: person.id, person: {first_name: 'John', last_name: 'Doe', email_address: {email: 'good_email@example.com'}, phone_number: {phone: '444-444-4444'}}, notify: '1'
          assert_response :success
          assert_equal(nil, assigns(:required_fields).detect(&:blank?))
          assert_not_nil(assigns(:new_person))
          assert_template 'leaders/create'
        end
      end
    end

    should "require gender, first name, last name and email when updating a leader" do
      person = Factory(:person)
      person.update_column(:gender, nil)
      xhr :put, :update, id: person.id, person: {first_name: '', last_name: '', email_address: {email: ''}, phone_number: {phone: ''}}, notify: '1'
      assert_response :success
      assert_equal("<font color='red'>Please fill in all fields<br />First Name is required.<br />Last Name is required.<br />Gender is required.<br />Email is required.<br /></font>", flash[:error])
      assert_template 'leaders/edit'
    end

    should "log a leader in from the special link" do
      token = SecureRandom.hex(12)
      @user.remember_token = token
      @user.remember_token_expires_at = 1.month.from_now
      @user.save(validate: false)
      get :leader_sign_in, token: token, user_id: @user.id
      assert_redirected_to '/dashboard'
    end

    should "should remove a leader" do
      user2 = Factory(:user_with_auxs)
      user3 = Factory(:user_with_auxs)
      Factory(:email_address, email: 'user2@email.com', person: user2.person)
      Factory(:email_address, email: 'user3@email.com', person: user3.person)
      user2.person.reload
      user3.person.reload
      @user.person.primary_organization.add_leader(user2.person, user3.person)
      assert_difference('OrganizationalPermission.where("archive_date" => nil).count', -1) do
        xhr :get,  :destroy, id: user2.person.id
        assert_response :success
      end
    end

    should "not be able to sign in leader" do
      get :leader_sign_in
      #assert_redirected_to user_root_path
      assert_response :redirect
    end
=begin
    should "reconcile the person comeing from a leader link with the link itself" do
      @user1, @org = admin_user_login_with_org


      token = SecureRandom.hex(12)
      @user.remember_token = token
      @user.remember_token_expires_at = 1.month.from_now
      @user.save(validate: false)
      get :leader_sign_in, token: token, user_id: @user.id
      #assert_redirected_to '/wizard?step=survey'
    end

=end
  end

  context "Seaching for Persons to be assigned a leader permission" do
    setup do
      @user = Factory(:user_with_auxs)
      @org = Factory(:organization)
      org_permission = Factory(:organizational_permission, organization: @org, person: @user.person, permission: Permission.admin)

      sign_in @user
      @request.session[:current_organization_id] = @org.id

      @permissions = []
      @permissions << Permission.user
      @permissions = @permissions.collect { |permission| permission.id }.join(',')
    end

    should "successfully find a searched Person if Person has valid email" do
      person = Factory(:person, first_name: "NeilMarion", email: "super_duper_unique_email@mail.com")
      assert_equal(Person.count, 2)
      xhr :get, :search, {"show_all"=>"", "name"=>"NeilMarion"}
      assert_response :success
    end

    should "successfully not find a searched Person if Person has an invalid email" do

    end

    should "not attempt to email if contact doesnt have a valid email" do
      person = Factory(:person)
      mail_count = ActionMailer::Base.deliveries.count
      assert(person.email, "")
      xhr :post, :create, { :person_id => person.id }
      assert_response :success
      assert_equal(mail_count, ActionMailer::Base.deliveries.count)
    end

    should "update the contact's permission to leader that has a valid email" do
      person = Factory(:person, email: "super_duper_unique_email@mail.com")
      xhr :post, :create, { :person_id => person.id }
      assert_response :success
      assert_equal(person.id, OrganizationalPermission.last.person_id)
      assert_equal("super_duper_unique_email@mail.com", ActionMailer::Base.deliveries.last.to.first.to_s)
    end

  end

end
