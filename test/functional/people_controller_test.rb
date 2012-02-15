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
      
      should "update roles with include_old_roles as parameter" do
        roles = []
        (1..3).each { |index| roles << Role.create!(organization_id: 1, name: "member_#{index}", i18n: "member_#{index}") }
        roles = roles.collect { |role| role.id }.join(',')
        xhr :post, :update_roles, { :role_ids => roles, :person_id => @person1.id, :include_old_roles => "yes" }
        assert_response :success
      end
      
      should "try to update roles with duplicate roles" do
        roles = []
        (1..3).each { |index| roles << Role.create!(organization_id: 1, name: "member_#{index}", i18n: "member_#{index}") }
        #duplicate the first role
        roles << roles.first
        roles = roles.collect { |role| role.id }.join(',')
        xhr :post, :update_roles, { :role_ids => roles, :person_id => @person1.id, :include_old_roles => "yes" }
        assert_response :success
      end
      
    end
  end
  
  context "When updating roles" do
    setup do
      @person = Factory(:person)
    end
    
    context "When user is admin" do
      setup do
        @user = Factory(:user_with_auxs)
        @org = Factory(:organization)
        org_role = Factory(:organizational_role, organization: @org, person: @user.person, role: Role.admin)
        
        sign_in @user
        @request.session[:current_organization_id] = @org.id
      end
      
      should "include admin role in label selection" do
        get :index
        assert(assigns(:roles).include? Role.admin)
      end
      
      should "update roles with include_old_roles as parameter" do
        roles = []
        (1..3).each { |index| roles << Role.create!(organization_id: @org.id, 
        name: "member_#{index}", i18n: "member_#{index}") }
        
        roles = roles.collect { |role| role.id }.join(',')
        xhr :post, :update_roles, { :role_ids => roles, :person_id => @person.id }
        assert_response :success
      end
    end
    
    context "When user is leader" do
      setup do
        @user = Factory(:user_with_auxs)
        user2 = Factory(:user_with_auxs)
        @org = Factory(:organization)
        org_role = Factory(:organizational_role, organization: @org, person: @user.person, role: Role.leader, :added_by_id => user2.person.id)
        
        sign_in @user
        @request.session[:current_organization_id] = @org.id
      end
      
      should "include admin role in label selection" do
        get :index
        assert(!(assigns(:roles).include? Role.admin))
      end
      
      should "update roles with include_old_roles as parameter" do
        roles = []
        (1..3).each { |index| roles << Role.create!(organization_id: @org.id, 
        name: "member_#{index}", i18n: "member_#{index}") }
        
        roles = roles.collect { |role| role.id }.join(',')
        xhr :post, :update_roles, { :role_ids => roles, :person_id => @person.id }
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

  context "Searching for Facebook users" do
    setup do
      @user = Factory(:user_with_auxs)  #user with a person object
      sign_in @user
    end

    #flash[:checker] came from the people_controller facebook_search method

    should "successfully search for facebook users when using '/http://www.facebook.com\//[a-z]' format" do
      get :facebook_search, { :term =>"http://www.facebook.com/nmfdelacruz"}
      assert_equal flash[:checker], 1, "Unsuccessfully searched for a user using Facebook profile url"
    end

    should "successfully search for facebook users when using '/http://www.facebook.com\/profile.php?id=/[0-9]'" do
      get :facebook_search, { :term =>"http://www.facebook.com/nmfdelacruz"}
      assert_equal flash[:checker], 1, "Unsuccessfully searched for a user using Facebook profile url"
    end

    should "unsuccessfully search for facebook users when url does not exist" do
      get :facebook_search, { :term =>"http://www.facebook.com/nm34523fdelacruz"}
      assert_equal flash[:checker], 0
    end

=begin These tests get errors because probably of facebook user authentication. RestClient::BadRequest: 400 Bad Request
    should "successfully search for facebook users when using '/[a-z]/' (name string)  format" do
      get :facebook_search, { :term =>"mark"}
      assert_equal flash[:checker], 1, "Unsuccessfully searched for a user using Facebook profile url"
    end

    should "unsuccessfully search for facebook users when name does not exist" do
      get :facebook_search, { :term =>"dj09345803oifjdlkjdl"}
      assert_equal flash[:checker], 0
    end
=end

  end
  
  context "displaying a person's friends in their profile" do
    setup do
      #setup user, orgs
      user = Factory(:user_with_auxs)
      sign_in user
      @org = Factory(:organization)
      #setup the person, and non-friends
      @person = Factory(:person_with_facebook_data)
      assert_not_nil(@person.friends)
      #create the person objects
      @person1 = Factory(:person, fb_uid: 3248973)
      @person2 = Factory(:person, fb_uid: 3343484)
      #add them in the org
      @org.add_contact(@person)
      @org.add_contact(@person1)
      @org.add_contact(@person2)
      @request.session['current_organization_id'] = @org.id
    end
    
    should "return the friends who are members of the same org as person" do
      #simulate their friendship with @person
      friend1 = Factory(:friend, person: @person)
      friend2 = Factory(:friend, person: @person)
      friend1.update_attributes(:uid => @person1.fb_uid)
      friend2.update_attributes(:uid => @person2.fb_uid)
      assert_not_nil(friend1.person)
      assert_not_nil(friend2.person)
      #profile view
      get :show, { 'id' => @person.id }
      #check the friends on the same org
      assert_not_nil(assigns(:org_friends))
      assert(assigns(:org_friends).include?@person1)
      assert(assigns(:org_friends).include?@person2)
      assert_equal(2, assigns(:org_friends).count)
    end
  end
  
  context "Assigning a contact to leader" do
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
    
    should "update the contact's role to leader that has a valid email" do
      person = Factory(:person, email: "test@mail.com")
      xhr :post, :update_roles, { :role_ids => @roles, :person_id => person.id }
      assert_response :success
      assert_equal(person.id, OrganizationalRole.last.person_id)
      assert_equal(1, ActionMailer::Base.deliveries.count)
    end
    
    should "not attempt to email if contact doesnt have a valid email" do
      person = Factory(:person)
      assert_nil(person.email)
      xhr :post, :update_roles, { :role_ids => @roles, :person_id => person.id }
      assert_response :success
      assert_equal(0, ActionMailer::Base.deliveries.count)
    end
  end
end
