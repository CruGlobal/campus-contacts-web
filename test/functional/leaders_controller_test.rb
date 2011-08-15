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
      # In the drect call, we're passing in a person_id that was clicked on
      xhr :post, :create, person_id: person.id
      assert_response :success
      # If the person is missing a user, a user should be created
    end
    
    # The create action gets called directly, and also by #add_person and #update
    should "should get create" do
      person = Factory(:person)
      # In the drect call, we're passing in a person_id that was clicked on
      xhr :post, :create, person_id: person.id
      assert_response :success
    end
      
    # should "should get destroy" do
    #   get :destroy
    #   assert_response :success
    # end
  end

end
