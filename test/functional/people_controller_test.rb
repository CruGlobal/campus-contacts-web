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
        p1 = PhoneNumber.new(:number => "123129312", :person_id => @person1.id)
        assert p1.save
        
        p2 = PhoneNumber.new(:number => "123i90900", :person_id => @person2.id, :primary => true)
        assert p2.save
        
        xhr :post, :bulk_sms, { :to => "#{@person1.id},#{@person2.id}", :body => "test sms body" }
        
        assert_response :success
        assert_not_nil assigns(:sent_sms)
      end      
    
      should "update roles" do
        roles = []
        (1..3).each { |index| roles << Role.create!(organization_id: 1, name: "member_#{index}", i18n: "member_#{index}") }
        roles = roles.collect { |role| role.id }.join(',')
        xhr :post, :update_roles, { :role_ids => roles, :some_role_ids => "", :person_id => @person1.id }
        assert_response :success
      end
      
      should "update roles with include_old_roles as parameter" do
        roles = []
        (1..3).each { |index| roles << Role.create!(organization_id: 1, name: "member_#{index}", i18n: "member_#{index}") }
        roles = roles.collect { |role| role.id }.join(',')
        xhr :post, :update_roles, { :role_ids => roles, :some_role_ids => "", :person_id => @person1.id, :include_old_roles => "yes" }
        assert_response :success
      end
      
      should "try to update roles with duplicate roles" do
        roles = []
        (1..3).each { |index| roles << Role.create!(organization_id: 1, name: "member_#{index}", i18n: "member_#{index}") }
        #duplicate the first role
        roles << roles.first
        roles = roles.collect { |role| role.id }.join(',')
        xhr :post, :update_roles, { :role_ids => roles, :some_role_ids => "", :person_id => @person1.id, :include_old_roles => "yes" }
        assert_response :success
      end
      
    end
  end
  
  context "When updating roles" do
    setup do
      @user = Factory(:user_with_auxs)

      @person = Factory(:person)
      @person2 = Factory(:person, email: "person2@email.com")
      @person3 = Factory(:person, email: "person3@email.com")

      @org = Factory(:organization)
      
      sign_in @user
      @request.session[:current_organization_id] = @org.id

      @roles = []
      (1..4).each { |index| @roles << Role.create!(organization_id: @org.id, name: "role_#{index}", i18n: "role_#{index}") }

    end

    should "retain old roles of different users even if users have initially have a different set of roles" do
      # Illustration:
      # @person2 initially have roles [3]
      # @person3 initially have roles [4]
      # Apply role "2" to both of them
      # @person2 and @person 3 should retain roles [3] and [4] respectively after PeopleController#update_roles

      OrganizationalRole.find_or_create_by_person_id_and_organization_id_and_role_id(person_id: @person2.id, role_id: 3, organization_id: @org.id, added_by_id: @user.person.id) # @person2 has role '1'      

      old_person_2_roles = @person2.organizational_roles.where(organization_id: @org.id).collect { |role| role.role_id }
      old_person_3_roles = @person3.organizational_roles.where(organization_id: @org.id).collect { |role| role.role_id }

      xhr :post, :update_roles, { :role_ids => "#{@roles[1].id}, #{@roles[2].id}", :some_role_ids => "#{@roles[2].id}, #{@roles[3].id}", :person_id => @person2.id }
      assert_response :success
      xhr :post, :update_roles, { :role_ids => "#{@roles[1].id}, #{@roles[3].id}", :some_role_ids => "#{@roles[2].id}, #{@roles[3].id}", :person_id => @person3.id }
      assert_response :success

      new_person_2_roles = @person2.organizational_roles.where(organization_id: @org.id).collect { |role| role.role_id }
      new_person_3_roles = @person3.organizational_roles.where(organization_id: @org.id).collect { |role| role.role_id }

      assert old_person_2_roles & new_person_2_roles # role 2 still has his old roles?
      assert old_person_3_roles & new_person_3_roles # role 3 still has his old roles?

    end
    
    context "removing an admin role" do
      setup do
        @last_admin = Factory(:person, email: "person4@email.com")
        @admin2 = Factory(:person, email: "person5@email.com")
        @admin_organizational_role = Factory(:organizational_role, organization: @org, person: @last_admin)
        @org.add_admin(@last_admin)
      end
      
      should "not remove admin role from the last admin of a root org" do
        assert_no_difference "OrganizationalRole.count" do
          xhr :post, :update_roles, { :role_ids => [], :some_role_ids => "", :person_id => @last_admin.id }
        end
      end
      
=begin
      should "not remove admin role from the last admin of an org with parent org with 'show_sub_orgs == false'" do
        setup do
          org_2 = Organization.create({"parent_id"=> @org.id, "name"=>"Org 2", "terminology"=>"Organization", "show_sub_orgs"=>"0"}) # org with show_sub_orgs == false
          org_3 = Organization.create({"parent_id"=> org_2.id, "name"=>"Org 3", "terminology"=>"Organization", "show_sub_orgs"=>"1"})
          @request.session[:current_organization_id] = org_3.id
        end
        
        org_3.add_admin(@user.person) unless org_3.parent && org_3.parent.show_sub_orgs?
        org_3.add_admin(@admin2)
        #puts org_3.admins.count
        @request.session['current_organization_id']  = org_3.id
        assert_no_difference "OrganizationalRole.count" do
          xhr :post, :update_roles, { :role_ids => [], :some_role_ids => "", :person_id => @user.person.id }
        end
      end
=end
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
      @person1 = Factory(:person)
      Factory(:contact_assignment, organization: user.person.organizations.first, assigned_to: user.person, person: @person1)
    end
    
    should "get the person assigned" do
      get :show, { 'id' => @person1.id }
      assert_response(:success)
      assert_not_nil(assigns(:assigned_tos))
    end
  end

  context "Searching for Facebook users" do
    setup do
      @user = Factory(:user_with_auxs)  #user with a person object
      sign_in @user
    end


    should "successfully search for facebook users when using '/http://www.facebook.com\//[a-z]' format" do
      stub_request(:get, "https://graph.facebook.com/nmfdelacruz").
        to_return(:body => "{\"id\":\"100000289242843\",\"name\":\"Neil Marion Dela Cruz\",\"first_name\":\"Neil Marion\",\"last_name\":\"Dela Cruz\",\"link\":\"http:\\/\\/www.facebook.com\\/nmfdelacruz\",\"username\":\"nmfdelacruz\",\"gender\":\"male\",\"locale\":\"en_US\"}")
      get :facebook_search, { :term =>"http://www.facebook.com/nmfdelacruz"}
      assert_equal(2, assigns(:data).length, "Unsuccessfully searched for a user using Facebook profile url")
    end

    #should "successfully search for facebook users when using '/http://www.facebook.com\/profile.php?id=/[0-9]'" do
      #get :facebook_search, { :term =>"http://www.facebook.com/nmfdelacruz"}
      #assert_equal @data.length, 1, "Unsuccessfully searched for a user using Facebook profile url"
    #end

    should "unsuccessfully search for facebook users when url does not exist" do
      stub_request(:get, "https://graph.facebook.com/nm34523fdelacruz").
        to_return(status: 404)
      get :facebook_search, { :term =>"http://www.facebook.com/nm34523fdelacruz"}
      assert_equal(1, assigns(:data).length)
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
      org_friends = assigns(:org_friends)
      assert_not_nil(org_friends)
      assert(org_friends.include?@person1)
      assert(org_friends.include?@person2)
      assert_equal(2, org_friends.length)
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
      person = Factory(:person, email: "super_duper_unique_email@mail.com")
      xhr :post, :update_roles, { :role_ids => @roles, :some_role_ids => "", :person_id => person.id, :added_by_id => @user.person.id }
      assert_response :success
      assert_equal(person.id, OrganizationalRole.last.person_id)
      assert_equal("super_duper_unique_email@mail.com", ActionMailer::Base.deliveries.last.to.first.to_s)
    end
    
    should "not attempt to email if contact doesnt have a valid email" do
      person = Factory(:person)
      mail_count = ActionMailer::Base.deliveries.count
      assert(person.email, "")
      xhr :post, :update_roles, { :role_ids => @roles, :some_role_ids => "", :person_id => person.id, :added_by_id => @user.person.id }
      assert_response :success
      assert_equal(mail_count, ActionMailer::Base.deliveries.count)
    end
    
    context "person has existing roles" do
      setup do
        @existing_roles = []
        @existing_roles << Role.contact
        @existing_roles << Role.leader
        @existing_roles = @existing_roles.collect { |role| role.id }.join(',')
      end
      
      should "append the leader role if the person already has existing roles" do
        person = Factory(:person, email: 'thisemailisalsounique@mail.com')
        Factory(:organizational_role, person: person, role: Role.contact, organization: @org, :added_by_id => @user.person.id)
        #check the persons roles
        assert_equal(1, person.roles.count)
        assert_equal(Role.contact, person.roles.last)
        xhr :post, :update_roles, { :role_ids => @existing_roles, :some_role_ids => "", :person_id => person, :added_by_id => @user.person.id }
        #assert that the leader role was not added
        assert_response :success
        assert_equal(2, person.roles.count)
        assert(person.roles.include? Role.leader)
        assert(person.roles.include? Role.contact)
        assert_equal(person.id, OrganizationalRole.last.person_id)
        assert_equal("thisemailisalsounique@mail.com", ActionMailer::Base.deliveries.last.to.first.to_s)
      end
    
      should "restore the person previous role if the person has an invalid email" do
        person = Factory(:person)        
        Factory(:organizational_role, person: person, role: Role.contact, organization: @org, :added_by_id => @user.person.id)
        #check the persons roles
        assert_equal(1, person.roles.count)
        assert_equal(Role.contact, person.roles.last)
        xhr :post, :update_roles, { :role_ids => @existing_roles, :some_role_ids => "", :person_id => person, :added_by_id => @user.person.id }
        #assert that the leader role was not added
        assert_response :success
        assert_equal(1, person.roles.count)
        assert_equal(Role.contact, person.roles.last)
      end
    end
  end
  
  context "Merging people" do
    setup do
      @user = Factory(:user_with_auxs)
      @org = Factory(:organization)
      sign_in @user
      @request.session[:current_organization_id] = @org.id
    end
    
    context "when the logged in user is admin" do
      setup do
        Factory(:organizational_role, organization: @org, person: @user.person, role: Role.admin)  
      end
      
      should "have access to the merge facility" do
        get :merge
        assert_response(:success)
      end
      
      context "merge people" do
        setup do
          @person1 = Factory(:person, firstName: "Clark", lastName: "Kent")
          @person2 = Factory(:person, firstName: "Bruce", lastName: "Wayne")
          @person3 = Factory(:person, firstName: "Hal", lastName: "Jordan")
          @person4 = Factory(:person, firstName: "Clark", lastName: "Kent")
          @person5 = Factory(:person, firstName: "clark", lastName: "kent")
        end
        
        should "fail to confirm_merge people when one of the 'mergees' have a different name" do
          post :confirm_merge, { :person1 =>  @person1.id, :person2 => @person2.id, :person3 => @person4.id }
          assert_response(:redirect)
          assert_equal("You can only merge people with the EXACT same first and last name.<br/>Go to the person's profile and edit their name to make them exactly the same and then try again.", flash[:alert])
        end
        
        should "fail to confirm merge when only one person is selected" do
          post :confirm_merge, { :person1 => @person1.id }
          assert_response :redirect
        end
        
        should "successfully confirm_merge peeps" do
          post :confirm_merge, { :person1 =>  @person1.id, :person2 => @person4.id }
          assert_response(:success)
        end
        
        should "successfully confirm_merge peeps with the same name but different casing" do
          post :confirm_merge, { :person1 =>  @person1.id, :person2 => @person5.id }
          assert_response(:success)
        end
      end
    end
    
    context "when the logged in user is a super admin" do
      setup do
        Factory(:super_admin, user: @user)
      end
      
      should "have access to the merge facility" do
        get :merge
        assert_response(:success)
      end
      
      context "merge people" do
        setup do
          @person1 = Factory(:person, firstName: "Tony", lastName: "Stark")
          @person2 = Factory(:person, firstName: "Thor", lastName: "Odinson")
          @person3 = Factory(:person, firstName: "Bruce", lastName: "Banner")
          @person4 = Factory(:person, firstName: "Tony", lastName: "Stark")
        end
        
        should "successfully confirm_merge peeps" do
          post :confirm_merge, { :person1 =>  @person1.id, :person2 => @person2.id, :person3 => @person3.id, :person4 => @person4.id }
          assert_response(:success)
        end 
      end
    end
    
    context "when the logged in user is a leader" do
      setup do
        Factory(:organizational_role, organization: @org, person: @user.person, role: Role.leader) 
      end
      
      should "not be allowed to use the merge facility" do
        get :merge
        assert_response(:redirect)
        assert_equal(flash[:error], "You are not permitted to access that feature")
      end
    end
  end
  
  context "merging people" do
    setup do
      @user, @org = admin_user_login_with_org
    end
    
    should "redirect when id = 0" do
      get :merge_preview, { :id => 0 }
      assert_response :success
    end
    
    should "get merge preview when id != 0" do
      p1 = Factory(:person)
      get :merge_preview, { :id => p1.id }
      assert_not_nil assigns(:person)
    end
    
    should "try to merge people" do
      p1 = Factory(:person)
      p2 = Factory(:person)
      p3 = Factory(:person)
      
      ids = []
      ids << p2.id
      ids << p3.id
      
      post :do_merge, { :keep_id => p1.id, :merge_ids => ids }
      
      assert_response :redirect
      assert_equal "You've just merged #{ids.length + 1} people", flash[:notice]
    end
  end
  
  context "searching ids" do
    setup do
      @user, @org = admin_user_login_with_org
      @another_org = Factory(:organization)
      c1 = Factory(:person, firstName: "Scott", lastName: "Munroe")
      c2 = Factory(:person, firstName: "Scott", lastName: "Summers")
      c3 = Factory(:person, firstName: "Scott", lastName: "Grey")
      
      @org.add_contact(c1)
      @org.add_contact(c2)
      @another_org.add_contact(c3)
    end
    
    should "only search ids within the org if user is not super admin" do
      xhr :get, :search_ids, { :q => "Scott" }
      assert_equal 2, assigns(:people).count
    end
    
    should "search all people when user is super admin" do
      Factory(:super_admin, user: @user)
      xhr :get, :search_ids, { :q => "Scott" }
      assert_equal 3, assigns(:people).count
    end
  end
  
  context "creating a person" do
    setup do
      request.env["HTTP_REFERER"] = "localhost:3000"
      @user, @org = admin_user_login_with_org
    end
    
    should "create person" do
      post :create, { :person => { :firstName => "Herp", :lastName => "Derp", :email_address => { :email => "herp@derp.com" }, :phone_number => { :number => "123918230912"} } }
      
      assert_not_nil assigns(:person)
      assert_not_nil assigns(:email)
      assert_not_nil assigns(:phone)
      
      assert_response :redirect
    end
    
    should "render nothing when user has no name" do
      post :create, { :person => { :firstName => "", :lastName => "Derp", :email_address => { :email => "herp@derp.com" }, :phone_number => { :number => "123918230912"} } }
      
      assert_equal " ", @response.body
    end
    
  end
  
  should "bulk delete" do
    @user, @org = admin_user_login_with_org
    c1 = Factory(:person)
    c2 = Factory(:person)
    
    @org.add_contact(c1)
    @org.add_contact(c2)
    
    assert_equal 2, @org.contacts.count
    xhr :post, :bulk_delete, { :ids => "#{c1.id}, #{c2.id}" }
    
    assert_equal 0, @org.contacts.count
    assert_equal " ", @response.body
  end
  
  should "bulk comment" do
    @user, @org = admin_user_login_with_org
    c1 = Factory(:person)
    c2 = Factory(:person)
    
    @org.add_contact(c1)
    @org.add_contact(c2)
    
    xhr :post, :bulk_comment, { :to => "#{c1.id}, #{c2.id}", :body => "WAT!" }
    
    assert FollowupComment.where(:contact_id => c1.id)
    assert FollowupComment.where(:contact_id => c2.id)
  end
  
    
  test "export" do
    @user, @org = admin_user_login_with_org
    
    3.times do
      p = Factory(:person)
      @org.add_contact(p)
    end
    
    get :export
    assert_response :success
  end
  
  test "involvement" do
    @user, @org = admin_user_login_with_org
    get :involvement, { :id => @user.person.id }
    
    assert_not_nil assigns(:person)
  end
  
  test "destroy" do
    @user, @org = admin_user_login_with_org
    person = Factory(:person)
    post :destroy, { :id => person.id }
    assert_response :success
  end
end
