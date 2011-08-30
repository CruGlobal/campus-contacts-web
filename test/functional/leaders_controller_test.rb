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
        assert_no_difference('User.count') do
          xhr :post, :add_person, person: {firstName: 'John', lastName: 'Doe', email_address: {email: 'new_user@example.com'}}, notify: '1' 
          assert_response :success
        end
      end
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
      
    # should "should get destroy" do
    #   get :destroy
    #   assert_response :success
    # end
  end

end
