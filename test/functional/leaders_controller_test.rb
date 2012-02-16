require 'test_helper'

class LeadersControllerTest < ActionController::TestCase
  
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
      assert_no_difference('OrganizationalRole.count') do
        assert_no_difference('User.count') do
          xhr :post, :create, person_id: person.id
          assert_response :success
        end
      end
      assert_template 'leaders/edit'
    end
    
    should "add a leader manually (already in db, but not in this org)" do
      user2 = Factory(:user_with_auxs)
      assert_difference('OrganizationalRole.count') do
        assert_no_difference('User.count') do
          xhr :post, :add_person, person: {firstName: 'John', lastName: 'Doe', email_address: {email: user2.username}}, notify: '1' 
          assert_response :success
        end
      end
    end
    
    should "add a leader manually (not already in db)" do 
      assert_difference('OrganizationalRole.count') do
        assert_difference('User.count') do
          assert_difference('Person.count') do
            xhr :post, :add_person, person: {firstName: 'John', lastName: 'Doe', gender: '1', email_address: {email: 'new_user@example.com'}, phone_number: {phone: '444-444-4444'}}, notify: '1' 
            assert_response :success 
            assert_equal(nil, flash[:error])
            assert_not_nil(assigns(:person).user, "New user didn't get created")
            assert_template 'leaders/create'
          end
        end
      end
    end
    
    should "require gender, first name, last name and email when adding a leader" do 
      xhr :post, :add_person, person: {firstName: '', lastName: '', email_address: {email: ''}, phone_number: {phone: ''}}, notify: '1' 
      assert_response :success 
      assert_equal('First Name is required.<br />Last Name is required.<br />Gender is required.<br />Email is required.<br />', flash[:error])
      assert_template 'leaders/new'
    end
    
    should "validate email when adding a leader" do 
      xhr :post, :add_person, person: {firstName: 'John', lastName: 'Doe', gender: '1', email_address: {email: 'Howie Koffman <howie.kauffman@facultycommons.org>'}, phone_number: {phone: '444-444-4444'}}, notify: '1' 
      assert_response :success 
      assert_equal("Email Address isn't valid.<br />", flash[:error])
      assert_template 'leaders/new'
    end
    
    should "update a person and add them as a leader" do
      person = Factory(:person)
      person.email = 'bad email'
      person.user = nil
      person.save(validate: false)
      assert_difference('OrganizationalRole.count') do
        assert_difference('User.count') do
          xhr :put, :update, id: person.id, person: {firstName: 'John', lastName: 'Doe', email_address: {email: 'good_email@example.com'}, phone_number: {phone: '444-444-4444'}}, notify: '1' 
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
      xhr :put, :update, id: person.id, person: {firstName: '', lastName: '', email_address: {email: ''}, phone_number: {phone: ''}}, notify: '1' 
      assert_response :success 
      assert_equal('Please fill in all fields<br />First Name is required.<br />Last Name is required.<br />Gender is required.<br />Email is required.<br />', flash[:error])
      assert_template 'leaders/edit'
    end
    
    should "log a leader in from the special link" do
      token = SecureRandom.hex(12)
      @user.remember_token = token
      @user.remember_token_expires_at = 1.month.from_now
      @user.save(validate: false)
      get :leader_sign_in, token: token, user_id: @user.id
      assert_redirected_to '/wizard?step=survey'
    end

    should "should remove a leader" do
      user2 = Factory(:user_with_auxs)
      user3 = Factory(:user_with_auxs)
      @user.person.primary_organization.add_leader(user2.person, user3.person)
      assert_difference('OrganizationalRole.count', -1) do
        xhr :get,  :destroy, id: user2.person.id
        assert_response :success
      end
    end
  end

  context "Seaching for Persons to be assigned a leader role" do
    setup do
      @user = Factory(:user_with_auxs)
      @org = Factory(:organization)
      org_role = Factory(:organizational_role, organization: @org, person: @user.person, role: Role.admin)
        
      sign_in @user
      @request.session[:current_organization_id] = @org.id
      
      @roles = []
      @roles << Role.leader
      @roles = @roles.collect { |role| role.id }.join(',')
    end

    should "successfully find a searched Person if Person has valid email" do
      person = Factory(:person, firstName: "NeilMarion", email: "super_duper_unique_email@mail.com")
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

    should "update the contact's role to leader that has a valid email" do
      person = Factory(:person, email: "super_duper_unique_email@mail.com")
      xhr :post, :create, { :person_id => person.id }
      assert_response :success
      assert_equal(person.id, OrganizationalRole.last.person_id)
      assert_equal("super_duper_unique_email@mail.com", ActionMailer::Base.deliveries.last.to.first.to_s)
    end

  end

end
