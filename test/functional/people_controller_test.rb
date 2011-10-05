require 'test_helper'

class PeopleControllerTest < ActionController::TestCase

  context "Before logging in" do
    
    should "redirect on update" do
      @person = Factory(:person)
      put :update, id: @person.id
      assert_redirected_to '/users/sign_in'
    end
    
  end
  
  context "After logging in a person without orgs" do
    setup do
      @person = Factory(:user_no_org)  
      sign_in @person
    end

    should "redirect on edit" do
      get :edit, id: @person.person.id
      assert_redirected_to '/wizard'      
    end
    
    should "redirect on update" do
      put :update, id: @person.id
      assert_redirected_to '/wizard'
    end
    
  end
  
  context "After logging in a person" do  

    setup do
      @person = Factory(:user_with_auxs)  #user with a person object
      sign_in @person
    end
    
    # 
    # test "should get index" do
    #   get :index
    #   assert_response :success
    #   assert_not_nil assigns(:people)
    # end
    # 
    # test "should get new" do
    #   get :new
    #   assert_response :success
    # end
    # 
    # test "should create person" do
    #   assert_difference('Person.count') do
    #     post :create, person: @person.attributes
    #   end
    # 
    #   assert_redirected_to person_path(assigns(:person))
    # end
    # 

    should "should show person" do
      get :show, id: @person.person.id
      assert_response :success, @response.body
    end
  
    should "should get edit" do
      get :edit, id: @person.person.id
      assert_response :success
    end
    # 
    should "should update person" do
      put :update, id: @person.person.id, person: {firstName: 'David', lastName: 'Ang',  :current_address_attributes => { :address1 => "#41 Sgt. Esguerra Ave", :country => "Philippines"} }
      #put :update, id: @person.person.id, person: @person.attributes
      assert_redirected_to person_path(assigns(:person))
    end
    # 
    # test "should destroy person" do
    #   assert_difference('Person.count', -1) do
    #     delete :destroy, id: @person.to_param
    #   end
    # 
    #   assert_redirected_to people_path
    # end
  
  end

end
