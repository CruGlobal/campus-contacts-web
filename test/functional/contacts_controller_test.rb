require 'test_helper'

class ContactsControllerTest < ActionController::TestCase
  context "Before logging in" do
    should "redirect on update" do
      @contact = Factory(:person)
      put :update, id: @contact.id
      assert_redirected_to '/users/sign_in'
    end
  end
  
  should "redirect when there is no current_organization" do
    get :index
    assert_response :redirect
  end
  
  context "After logging in a person with orgs" do
    setup do
      @user, org = admin_user_login_with_org
      @keyword = Factory.create(:sms_keyword)
      @user.person.organizations.first.add_leader(@user.person, @user.person)
      @org = org
    end
    
    context "creating a new contact manually" do
      should "create a person with only an email address" do
        xhr :post, :create, {"assigned_to" => "all", "dnc" => "", "person" => {"email_address" => {"email" => "test@uscm.org"},"firstName" => "Test","lastName" => "Test",  "phone_number" => {"number" => ""}}}
        assert_response :success, @response.body
      end
    
      should "create a person with email and phone number" do
        xhr :post, :create, {
                        "person" => {
                          "current_address_attributes" => {
                            "country" => "US"
                          },
                          "email_address" => {
                            "_destroy" => "false",
                            "email" => "trbooth@uark.edu",
                            "primary" => "0"
                          },
                          "firstName" => "Tyler",
                          "gender" => "male",
                          "lastName" => "Booth",
                          "phone_number" => {
                            "_destroy" => "false",
                            "location" => "mobile",
                            "number" => "479-283-4946",
                            "primary" => "0"
                          }
                        }
                      }
        assert_response :success, @response.body 
      end
    
      should "render the form with errors if email is bad" do
        xhr :post, :create, {
                        "person" => {
                          "email_address" => {
                            "email" => "trbooth@asdf",
                          },
                          "firstName" => "Tyler",
                          "gender" => "male",
                          "lastName" => "Booth",
                          "phone_number" => {
                            "number" => "479-283-4946",
                          }
                        }
                      }
        assert_response :success, @response.body 
      end
      
      should "remove the being 'archived' Contact role of a Person when it is going to be created again (using existing firstName, lastName and email) in 'My Contacts' tab (:assign_to_me => true)" do
        contact = Factory(:person, firstName: "Jon", lastName: "Snow")
        email = Factory(:email_address, email: "jonsnow@email.com", person: contact)
        Factory(:organizational_role, role: Role.contact, person: contact, organization: @org)
        assert_not_empty contact.organizational_roles.where(role_id: Role.contact.id)
        assert_not_empty @org.contacts.joins(:email_addresses).where(firstName: "Jon", lastName: "Snow", "email_addresses.email" => "jonsnow@email.com")
        #archive contact role
        contact.organizational_roles.where(role_id: Role.contact.id).first.archive
        assert_empty contact.organizational_roles.where(role_id: Role.contact.id)
        assert_empty @org.contacts.joins(:email_addresses).where(firstName: "Jon", lastName: "Snow", "email_addresses.email" => "jonsnow@email.com")
        xhr :post, :create, {:assign_to_me => "true", :person => {:firstName => "Jon", :lastName => "Snow", :gender =>"male", :email_address => {:email => "jonsnow@email.com", :primary => 1}}}
        assert_not_empty contact.organizational_roles.where(role_id: Role.contact.id), "Contact role of contact not unarchived"
        assert_not_empty @org.contacts.joins(:email_addresses).where(firstName: "Jon", lastName: "Snow", "email_addresses.email" => "jonsnow@email.com")
      end
      
      should "remove the being 'archived' Contact role of a Person when it is going to be created again (using existing firstName, lastName and email) in 'All Contacts' tab" do
        contact = Factory(:person, firstName: "Jon", lastName: "Snow")
        email = Factory(:email_address, email: "jonsnow@email.com", person: contact)
        Factory(:organizational_role, role: Role.contact, person: contact, organization: @org)
        assert_not_empty contact.organizational_roles.where(role_id: Role.contact.id)
        assert_not_empty @org.contacts.joins(:email_addresses).where(firstName: "Jon", lastName: "Snow", "email_addresses.email" => "jonsnow@email.com")
        #archive contact role
        contact.organizational_roles.where(role_id: Role.contact.id).first.archive
        assert_empty contact.organizational_roles.where(role_id: Role.contact.id)
        assert_empty @org.contacts.joins(:email_addresses).where(firstName: "Jon", lastName: "Snow", "email_addresses.email" => "jonsnow@email.com")
        xhr :post, :create, {:person => {:firstName => "Jon", :lastName => "Snow", :gender =>"male", :email_address => {:email => "jonsnow@email.com", :primary => 1}}}
        assert_not_empty contact.organizational_roles.where(role_id: Role.contact.id), "Contact role of contact not unarchived"
        assert_not_empty @org.contacts.joins(:email_addresses).where(firstName: "Jon", lastName: "Snow", "email_addresses.email" => "jonsnow@email.com")
      end
    end
    
    context "on index page" do
      setup do
        @organization = Factory(:organization) 
        @keyword = Factory(:approved_keyword, organization: @organization)
        get :index, org_id: @organization.id
      end
      should respond_with(:success)
    end
    
    should "update a contact's info" do
      @contact = Factory(:person)
      @user.person.organizations.first.add_contact(@contact)
      put :update, id: @contact.id, person: {firstName: 'Frank'}
      assert_redirected_to survey_response_path(@contact)
      assert_equal(assigns(:person).id, @contact.id)
    end
    
    should "remove a contact from an organization" do   
       @contact = Factory(:person)
       @user.person.organizations.first.add_contact(@contact)         
       
       xhr :delete, :destroy, :id => @contact.id
       assert_response :success        
    end 
    
    should "bulk remove contacts from an organization" do   
       @contact = Factory(:person)
       @contact2 = Factory(:person)         
       @user.person.organizations.first.add_contact(@contact)                
       
       xhr :post, :bulk_destroy, :ids => [@contact.id, @contact2.id]       
       assert_response :success        
    end
    
    should "Have a header for every params[:assigned_to]" do
      @contact1 = Factory(:person)
      @contact2 = Factory(:person)
      @contact3 = Factory(:person)
      @contact4 = Factory(:person)
      @contact5 = Factory(:person)
      @user.person.organizations.first.add_leader(@user.person, @user.person)
      @user.person.organizations.first.add_contact(@contact1)
      @user.person.organizations.first.add_contact(@contact2)
      @user.person.organizations.first.add_contact(@contact3)
      @user.person.organizations.first.add_contact(@contact4)
      @user.person.organizations.first.add_contact(@contact5)
      
    
      xhr :get, :index, {:role => Role::ADMIN_ID}
      assert_equal assigns(:header).upcase, "Admin".upcase
      xhr :get, :index, {:role => Role::LEADER_ID}
      assert_equal assigns(:header).upcase, "Leader".upcase
      xhr :get, :index, {:role => Role::CONTACT_ID}
      assert_equal assigns(:header).upcase, "Contact".upcase
      xhr :get, :index, {:role => Role::INVOLVED_ID}
      assert_equal assigns(:header).upcase, "Involved".upcase
      xhr :get, :index, {:assigned_to => "unassigned"}
      assert_equal assigns(:header), "Unassigned"
      xhr :get, :index, {:assigned_to => "progress"}
      assert_equal assigns(:header), "Assigned"
      xhr :get, :index, {:completed => "true"}
      assert_equal assigns(:header), "Completed"
      xhr :get, :index, {:assigned_to => nil}
      assert_nil assigns(:header)
      xhr :get, :index, {:assigned_to => "no_activity"}
      assert_equal assigns(:header), "No Activity"
      xhr :get, :index, {:assigned_to => "spiritual_conversation"}
      assert_equal assigns(:header), "Spiritual Conversation"
      xhr :get, :index, {:assigned_to => "prayed_to_receive"}
      assert_equal assigns(:header), "Prayed To Receive Christ"
      xhr :get, :index, {:assigned_to => "gospel_presentation"}
      assert_equal assigns(:header), "Gospel Presentation"
      xhr :get, :index, {:assigned_to => "friends"}
      assert_equal assigns(:header), "Contacts who are also my friends on Facebook"
      xhr :get, :index, {:dnc => "true"}
      assert_equal assigns(:header), "Do Not Contact"
      xhr :get, :index, {:search => "1"}
      assert_equal assigns(:header), "Matching the criteria you searched for"
      xhr :get, :index, {:assigned_to => @user.person.personID}
      assert_equal assigns(:header), "Assigned to #{@user.person.name}"
    end
  
  end
  
  context "When retrieving roles depending on current user role" do
    context "When user is admin" do
      setup do
        @user = Factory(:user_with_auxs)  #user with a person object
        org = Factory(:organization)
        Factory(:organizational_role, person: @user.person, role: Role.admin, organization: org)
        sign_in @user
        @request.session[:current_organization_id] = org.id
      end
      
      should "get all roles" do
        get :index
        assert_response(:success)
        assert(assigns(:roles_for_assign).include? Role.admin)
        
        get :mine
        assert_response(:success)
        assert(assigns(:roles_for_assign).include? Role.admin)
      end
    end
    
    context "When user is leader" do
      setup do
        @user = Factory(:user_with_auxs)
        @user2 = Factory(:user_with_auxs)
        org = Factory(:organization)
        Factory(:organizational_role, person: @user.person, role: Role.leader, organization: org, :added_by_id => @user2.person.id)
        sign_in @user
        @request.session[:current_organization_id] = org.id
      end
      
      should "not include admin role if user is not admin" do
        get :index
        assert_response(:success)
        assert(!(assigns(:roles_for_assign).include? Role.admin))
        
        get :mine
        assert_response(:success)
        assert(!(assigns(:roles_for_assign).include? Role.admin))
      end
    end
    
  end  
  
  context "After logging in a person without orgs" do
    setup do
      #@user = Factory(:user)
      @user = Factory(:user_no_org)  #user with a person object
      sign_in @user
      @organization = Factory(:organization)
      @keyword = Factory.create(:approved_keyword, organization: @organization)
    end
    
    context "on index page" do
      setup do
        get :index
      end
      should redirect_to '/wizard'
    end
    
  end

  context "After logging in as a contact" do
    setup do
      @user = Factory(:user_no_org)  #user with a person object
      @organization = Factory(:organization)
      @organization_membership = Factory(:organization_membership, person: @user.person, organization: @organization)
      @organizational_role = Factory(:organizational_role, person: @user.person, organization: @organization, :role => Role.contact)
      sign_in @user
    end
    
    context "on index page" do
      setup do
        get :index
      end
      should redirect_to('/wizard') 
    end
  end
  
  test "send reminder" do
    Resque.reset!
    user1 = Factory(:user_with_auxs)
    user2 = Factory(:user_with_auxs)
    
    user, org = admin_user_login_with_org

    #org.add_leader(user1.person, user.person)
    #org.add_leader(user2.person, user.person)
    Factory(:organizational_role, person: user1.person, organization: org, role: Role.leader)
    Factory(:organizational_role, person: user2.person, organization: org, role: Role.leader)
    
    xhr :post, :send_reminder, { :to => "#{user1.person.id}, #{user2.person.id}" }
    
    assert_equal " ", response.body
    assert_queued(ContactsMailer)
    #assert_equal 1, ActionMailer::Base.deliveries.count
  end

  test "find people by name or meail given wildcard strings" do
    user1 = Factory(:user_with_auxs)
    user2 = Factory(:user_with_auxs)
    
    user, org = admin_user_login_with_org
    Factory(:organizational_role, organization: org, person: user.person, role: Role.leader)
    person1 = Factory(:person, firstName: "Neil Marion", lastName: "dela Cruz", email: "ndc@email.com")
    Factory(:organizational_role, organization: org, person: person1, role: Role.contact)
    person2 = Factory(:person, firstName: "Johnny", lastName: "English", email: "english@email.com")
    Factory(:organizational_role, organization: org, person: person2, role: Role.contact)
    person3 = Factory(:person, firstName: "Johnny", lastName: "Bravo", email: "bravo@email.com")
    Factory(:organizational_role, organization: org, person: person3, role: Role.contact)
    
    xhr :get, :search_by_name_and_email, { :term => "Neil" } # should be able to find a leader as well
    assert_response :success, response
    res = ActiveSupport::JSON.decode(response.body)
    assert_equal res[0]['id'], person1.id
    assert_equal res[0]['label'], "#{person1.name} (#{person1.email})"

    xhr :get, :search_by_name_and_email, { :term => "ndc" } #should be able to find by an email address wildcard
    assert_response :success, response
    res = ActiveSupport::JSON.decode(response.body)
    assert_equal res[0]['id'], person1.id
    assert_equal res[0]['label'], "#{person1.name} (#{person1.email})"

    xhr :get, :search_by_name_and_email, { :term => "hnny" } #should be able to find contacts
    assert_response :success, response
    res = ActiveSupport::JSON.decode(response.body)
    assert_equal res.count, 2
  end
  
  context "Searching for contacts using 'Saved Searches'" do
    setup do
      @user = Factory(:user_with_auxs)
      sign_in @user
      
      @contact1 = Factory(:person, firstName: "Neil", lastName: "delaCruz")
      @user.person.organizations.first.add_contact(@contact1)
    end
  
    should "search for contacts" do
      xhr :get, :index, {:search => "1", :firstName => "Neil", :lastName => "delaCruz"}
      assert_response :success
    end
    #more tests to come
  end
end
