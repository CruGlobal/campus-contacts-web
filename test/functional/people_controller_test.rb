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

    context "bulk sending" do
      setup do
        @person1 = Factory(:person)
        @person2 = Factory(:person)        
      end
      
      should "send bulk email" do
        xhr :post, :bulk_email, { :to => "#{@person1.id},#{@person2.id}", :subject => "functional test", :body => "test email body" }
        
        assert_response :success
      end
      
      should "send bulk sms" do
        xhr :post, :bulk_sms, { :to => "#{@person1.id},#{@person2.id}", :body => "test sms body" }
        
        assert_response :success
      end      
    
      should "update roles" do
        roles = []
        (1..3).each { |index| roles << Role.create!(organization_id: 1, name: "member_#{index}", i18n: "member_#{index}") }
        roles = roles.collect { |role| role.id }.join(',')
        xhr :post, :update_roles, { :role_ids => roles, :person_id => @person1.id }
        assert_response :success
      end
    end
  end
  
  context "Search" do
    setup do
      @user = Factory(:user_with_auxs)
      sign_in @user
    end
    
    should "respond success with no parameters" do
      get :index
      assert_response(:success)
    end
    
    should "respond success with basic search parameter" do
      get :index, :search_type => "basic", :query => "John Doe"
      assert_response(:success)
    end
    
    should "respond success with advanced search parameters" do
      get :index, :search_type => "advanced", :first_name => "John", :last_name => "Doe", :role => "1", :gender => "1", 
          :email => "test@email.com", :phone => "123"
      assert_response(:success)
    end
  end
  
  context "Showing leaders the person is assigned to" do
    setup do
      user = Factory(:user_with_auxs)
      sign_in user
      @org1 = Factory(:organization)
      @person1 = Factory(:person)
      @person2 = Factory(:person)
      Factory(:contact_assignment, organization: @org1, assigned_to: @person2, person: @person1)
    end
    
    should "get the person assigned" do
      get :show, { 'id' => @person1.id }
      assert_response(:success)
      assert_not_nil(assigns(:person).assigned_tos)
      assert_not_nil(assigns(:assigned_tos))
    end
  end

end
