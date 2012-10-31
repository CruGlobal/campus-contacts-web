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
    
    should "be able to show a person" do
      xhr :get, :show, {:id => @user.person.id}
      assert_response :redirect
    end
    
    should "be able to edit a person" do
      xhr :get, :edit, {:id => @user.person.id}
      assert_response :redirect
    end
    
    context "creating a new contact manually" do
      should "create a person with only an email address" do
        xhr :post, :create, {"assigned_to" => "all", "dnc" => "", "person" => {"email_address" => {"email" => "test@uscm.org"},"first_name" => "Test","last_name" => "Test",  "phone_number" => {"number" => ""}}}
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
                          "first_name" => "Tyler",
                          "gender" => "male",
                          "last_name" => "Booth",
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
                          "first_name" => "Tyler",
                          "gender" => "male",
                          "last_name" => "Booth",
                          "phone_number" => {
                            "number" => "479-283-4946",
                          }
                        }
                      }
        assert_response :success, @response.body 
      end
      
      should "create a person even though inserted email has trailing spaces" do
      
        assert_difference "Person.count" do
          xhr :post, :create, {
                          "person" => {
                            "email_address" => {
                              "email" => "trboothshoomy@email.com ",
                            },
                            "first_name" => "Tyler",
                            "gender" => "male",
                            "last_name" => "Booth",
                            "phone_number" => {
                              "number" => "479-283-4946",
                            }
                          }
                        }
                        
          end
        assert_response :success, @response.body 
      end
      
      should "remove the being 'archived' Contact role of a Person when it is going to be created again (using existing first_name, last_name and email) in 'My Contacts' tab (:assign_to_me => true)" do
        contact = Factory(:person, first_name: "Jon", last_name: "Snow")
        email = Factory(:email_address, email: "jonsnow@email.com", person: contact)
        Factory(:organizational_role, role: Role.contact, person: contact, organization: @org)
        assert_not_empty contact.organizational_roles.where(role_id: Role.contact.id)
        assert_not_empty @org.contacts.joins(:email_addresses).where(first_name: "Jon", last_name: "Snow", "email_addresses.email" => "jonsnow@email.com")
        #archive contact role
        contact.organizational_roles.where(role_id: Role.contact.id).first.archive
        assert_empty contact.organizational_roles.where(role_id: Role.contact.id)
        assert_empty @org.contacts.joins(:email_addresses).where(first_name: "Jon", last_name: "Snow", "email_addresses.email" => "jonsnow@email.com")
        xhr :post, :create, {:assign_to_me => "true", :person => {:first_name => "Jon", :last_name => "Snow", :gender =>"male", :email_address => {:email => "jonsnow@email.com", :primary => 1}}}
        assert_not_empty contact.organizational_roles.where(role_id: Role.contact.id), "Contact role of contact not unarchived"
        assert_not_empty @org.contacts.joins(:email_addresses).where(first_name: "Jon", last_name: "Snow", "email_addresses.email" => "jonsnow@email.com")
      end
      
      should "remove the being 'archived' Contact role of a Person when it is going to be created again (using existing first_name, last_name and email) in 'All Contacts' tab" do
        contact = Factory(:person, first_name: "Jon", last_name: "Snow")
        email = Factory(:email_address, email: "jonsnow@email.com", person: contact)
        Factory(:organizational_role, role: Role.contact, person: contact, organization: @org)
        assert_not_empty contact.organizational_roles.where(role_id: Role.contact.id)
        assert_not_empty @org.contacts.joins(:email_addresses).where(first_name: "Jon", last_name: "Snow", "email_addresses.email" => "jonsnow@email.com")
        #archive contact role
        contact.organizational_roles.where(role_id: Role.contact.id).first.archive
        assert_empty contact.organizational_roles.where(role_id: Role.contact.id)
        assert_empty @org.contacts.joins(:email_addresses).where(first_name: "Jon", last_name: "Snow", "email_addresses.email" => "jonsnow@email.com")
        xhr :post, :create, {:person => {:first_name => "Jon", :last_name => "Snow", :gender =>"male", :email_address => {:email => "jonsnow@email.com", :primary => 1}}}
        assert_not_empty contact.organizational_roles.where(role_id: Role.contact.id), "Contact role of contact not unarchived"
        assert_not_empty @org.contacts.joins(:email_addresses).where(first_name: "Jon", last_name: "Snow", "email_addresses.email" => "jonsnow@email.com")
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
      put :update, id: @contact.id, person: {first_name: 'Frank'}
      assert_redirected_to survey_response_path(@contact)
      assert_equal(assigns(:person).id, @contact.id)
    end
    
    should "update an invalid contact's info'" do
      @contact = Factory.build(:person_without_name) 
      @contact.save(validate: false)
      @user.person.organizations.first.add_contact(@contact)
      put :update, id: @contact.id, person: {last_name: 'Jake'}
      assert_redirected_to survey_response_path(@contact)
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
      xhr :get, :index, {:assigned_to => @user.person.id}
      assert_equal assigns(:header), "Assigned to #{@user.person.name}"
    end
    
    should "get unassigned contacts ONLY" do
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
      
      @contact5.organizational_roles.first.update_attributes({:deleted => 1})
      xhr :get, :index, {:assigned_to => "unassigned"}
      assert_equal assigns(:all_people).collect(&:id).sort, [@contact1.id, @contact2.id, @contact3.id, @contact4.id]
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
  
  context "Search by name or email" do
    setup do
      @user1 = Factory(:user_with_auxs)
      @user2 = Factory(:user_with_auxs)
      
      @user, @org = admin_user_login_with_org
      Factory(:organizational_role, organization: @org, person: @user.person, role: Role.leader)
      @person1 = Factory(:person, first_name: "Neil Marion", last_name: "dela Cruz", email: "ndc@email.com")
      Factory(:organizational_role, organization: @org, person: @person1, role: Role.contact)
      @person2 = Factory(:person, first_name: "Johnny", last_name: "English", email: "english@email.com")
      Factory(:organizational_role, organization: @org, person: @person2, role: Role.contact)
      @person3 = Factory(:person, first_name: "Johnny", last_name: "Bravo", email: "bravo@email.com")
      Factory(:organizational_role, organization: @org, person: @person3, role: Role.contact)
      @person4 = Factory(:person, first_name: "Neil", last_name: "O'neil", email: "neiloneil@email.com")
      Factory(:organizational_role, organization: @org, person: @person4, role: Role.contact)
    end
  

    should "find people by name or email given wildcard strings" do
      
      
      xhr :get, :search_by_name_and_email, { :term => "Neil" } # should be able to find a leader as well
      assert_response :success, response
      res = ActiveSupport::JSON.decode(response.body)
      assert_equal res[0]['id'], @person1.id
      assert_equal res[0]['label'], "#{@person1.name} (#{@person1.email})"

      xhr :get, :search_by_name_and_email, { :term => "ndc" } #should be able to find by an email address wildcard
      assert_response :success, response
      res = ActiveSupport::JSON.decode(response.body)
      assert_equal res[0]['id'], @person1.id
      assert_equal res[0]['label'], "#{@person1.name} (#{@person1.email})"

      xhr :get, :search_by_name_and_email, { :term => "hnny" } #should be able to find contacts
      assert_response :success, response
      res = ActiveSupport::JSON.decode(response.body)
      assert_equal res.count, 2
      
      xhr :get, :search_by_name_and_email, { :term => "O'neil" } # should be able to find a person even a wildcard has non-alpha characters
      assert_response :success, response
      res = ActiveSupport::JSON.decode(response.body)
      assert_equal res[0]['id'], @person4.id
      assert_equal res[0]['label'], "#{@person4.name} (#{@person4.email})"
    end
    
    should "strip trailing whitespaces of search terms" do
      xhr :get, :search_by_name_and_email, { :term => "Neil     " }
      assert_response :success, response
      res = ActiveSupport::JSON.decode(response.body)
      assert_equal res[0]['id'], @person1.id
      assert_equal res[0]['label'], "#{@person1.name} (#{@person1.email})"
    end
  
  end
  
  context "Searching for contacts using 'Saved Searches'" do
    setup do
      @user = Factory(:user_with_auxs)
      sign_in @user
      
      @contact1 = Factory(:person, first_name: "Neil", last_name: "delaCruz")
      @user.person.organizations.first.add_contact(@contact1)
    end
  
    should "search for contacts" do
      xhr :get, :index, {:search => "1", :first_name => "Neil", :last_name => "delaCruz"}
      assert_response :success
    end
    #more tests to come
  end
  
  context "Searching for people using search_autocomplete_field" do
    setup do
      @user = Factory(:user_with_auxs)
      sign_in @user
      
      @archived_contact1 = Factory(:person, first_name: "Edmure", last_name: "Tully")
      Factory(:organizational_role, organization: @user.person.organizations.first, person: @archived_contact1, role: Role.contact)
      @archived_contact1.organizational_roles.where(role_id: Role::CONTACT_ID).first.archive #archive his one and only role
      
      @unarchived_contact1 = Factory(:person, first_name: "Brynden", last_name: "Tully")
      Factory(:organizational_role, organization: @user.person.organizations.first, person: @unarchived_contact1, role: Role.contact)
      Factory(:email_address, email: "bryndentully@email.com", person: @unarchived_contact1, primary: true)
    end
    
    should "not be able to search for archived contacts if 'Include Archvied' checkbox is not checked" do
      get :search_by_name_and_email, {:term => "Edmure Tully"}
      assert !assigns(:people).include?(@archived_contact1)
    end
    
    should "be able to search for archived contacts if 'Include Archvied' checkbox is checked" do
      get :search_by_name_and_email, {:include_archived => "true", :term => "Edmure Tully"}
      assert assigns(:people).include?(@archived_contact1)
    end
    
    should "be able to search by email address" do
      get :search_by_name_and_email, {:term => "Brynden Tully"}
      assert assigns(:people).include?(@unarchived_contact1)
    end
    
    should "be able to search by wildcard" do
      get :search_by_name_and_email, {:include_archived => "true", :term => "tully"}
      assert assigns(:people).include?(@archived_contact1), "archived contact not found"
      assert assigns(:people).include?(@unarchived_contact1), "unarchived contact not found"
    end
    
    should "not be able to search for anything" do
      get :search_by_name_and_email, {:include_archived => "true", :term => "none"}
      assert_empty assigns(:people)
    end
  end
  
  context "exporting contacts" do
    setup do
      @user, org = admin_user_login_with_org
      @contact1 = Factory(:person)
      @contact2 = Factory(:person)
      Factory(:organizational_role, role: Role.contact, organization: org, person: @contact1) #make them contacts in the org
      Factory(:organizational_role, role: Role.contact, organization: org, person: @contact2) #make them contacts in the org
      
      @survey = Factory(:survey, organization: org) #create survey
      @keyword = Factory(:approved_keyword, organization: org, survey: @survey) #create keyword
      @notify_q = Factory(:choice_field, notify_via: "Both", trigger_words: "Jesus") #create question
      @email_q = Factory(:email_element)
      @survey.questions << @notify_q
      @survey.questions << @email_q
      @questions = @survey.questions
      assert_equal(@questions.count, 2)
      
      
      @answer_sheet = Factory(:answer_sheet, survey: @survey, person: @contact1)
      @answer = Factory(:answer, answer_sheet: @answer_sheet, question: @notify_q, value: "Jesus", short_value: "Jesus")
    end
  
    should "export" do
      xhr :get, :index, {:assigned_to => "all", :format => "csv"}
      assert_response :success
    end
  
  end
  
  context "retrieving contacts" do
    setup do
      @user, org = admin_user_login_with_org
      @contact1 = Factory(:person)
      @contact2 = Factory(:person)
      Factory(:organizational_role, role: Role.contact, organization: org, person: @contact1) #make them contacts in the org
      Factory(:organizational_role, role: Role.contact, organization: org, person: @contact2) #make them contacts in the org
      
      @survey = Factory(:survey, organization: org) #create survey
      @keyword = Factory(:approved_keyword, organization: org, survey: @survey) #create keyword
      @notify_q = Factory(:choice_field, notify_via: "Both", trigger_words: "Jesus") #create question
      @email_q = Factory(:email_element)
      @phone_q = Factory(:phone_element)
      @gender_q = Factory(:gender_element)
      @some_q = Factory(:some_question)
      #puts @some_q.object_name.present?
      #puts @some_q.inspect
      @survey.questions << @notify_q
      @survey.questions << @email_q
      @survey.questions << @phone_q
      @survey.questions << @gender_q
      @survey.questions << @some_q
      @questions = @survey.questions
      assert_equal(@questions.count, 5)
      
      @answer_sheet = Factory(:answer_sheet, survey: @survey, person: @contact1)
      @answer = Factory(:answer, answer_sheet: @answer_sheet, question: @notify_q, value: "Jesus", short_value: "Jesus")
      
      @phone_number = Factory(:phone_number, person: @contact1, number: "09167788889", primary: true)
    end
    
    should "retrieve 'mine' contacts" do
      xhr :get, :mine, {:status => "completed"}
      assert_response :success
    end
    
    should "retrieve contacts with survey answers" do
      xhr :get, :index, {:search => 1, :answers => {"#{@notify_q.id}" => {"1" => 1, "2" => 2}, "#{@email_q.id}" => "email@email.com", "#{@some_q.id}" => "hello", "#{@phone_q.id}" => "12311311231231", "#{@gender_q.id}" => "male"}}
      assert_response :success
    end
    
    should "retrive contacts according to latest answer sheets answered" do
    
      xhr :get, :index, {:search => 1, "q"=>{"s"=>"MAX(answer_sheets.updated_at) asc"}}
      assert_response :success
    end
    
    should "retrive contacts according to surveys answered" do
      xhr :get, :index, {:search => 1, :survey => @survey.id}
      assert_response :success
    end
    
    should "retrive contacts searching by first_name" do
      xhr :get, :index, {:search => 1, :first_name => "Neil"}
      assert_response :success
    end
    
    should "retrive contacts searching by last_name" do
      xhr :get, :index, {:search => 1, :last_name => "dela Cruz"}
      assert_response :success
    end
    
    should "retrive contacts searching by email" do
      xhr :get, :index, {:search => 1, :email => "email@email.com"}
      assert_response :success
    end
    
    should "retrive contacts searching by phone_number" do
      xhr :get, :index, {:search => 1, :phone_number => "09167788889"}
      assert_equal [@contact1], assigns(:people)
      assert_response :success
    end
    
    should "retrive contacts searching by phone_number wildcard" do
      xhr :get, :index, {:search => 1, :phone_number => "88889"}
      assert_equal [@contact1], assigns(:people)
      assert_response :success
    end
    
    should "retrive contacts searching by gender" do
      xhr :get, :index, {:search => 1, :gender => "Male"}
      assert_response :success
    end
    
    should "retrive contacts searching by status" do
      xhr :get, :index, {:search => 1, :status => "uncontacted"}
      assert_response :success
    end
    
    should "retrive contacts searching by date updated" do
      xhr :get, :index, {:search => 1, :person_updated_from => "05-08-2012", :person_updated_to => "05-08-2012"}
      assert_response :success
    end
    
    should "retrive contacts searching by basic search_type" do
      xhr :get, :index, {:search => 1, :search_type => "basic"}
      assert_response :success
    end
  end
  
  context "Creating contacts" do
    setup do
      @user, org = admin_user_login_with_org
      @predefined_survey = Factory(:survey, organization: @org)
      APP_CONFIG['predefined_survey'] = @predefined_survey.id
      @year_in_school_question = Factory(:year_in_school_element)
      @predefined_survey.questions << @year_in_school_question
    end
    
    should "create an org with answered predefined survey" do
      assert_difference "Person.count", 1 do
        xhr :post, :create, {:person => {:first_name => "James", :last_name => "Ingram", :gender => "male"}, :answers => {"#{@year_in_school_question.id}"=>"4th"}  }
      end
      
      assert_equal "4th", Person.where(first_name: "James", last_name: "Ingram").first.year_in_school
    end
  end
  
  context "Sorting contacts" do
    setup do
      @user, org = admin_user_login_with_org
      
      @person1 = Factory(:person)
      @role1 = Factory(:organizational_role, organization: org, role: Role.contact, person: @person1)
      @role1.update_attributes({followup_status: "uncontacted"})
      @person2 = Factory(:person)
      @role2 = Factory(:organizational_role, organization: org, role: Role.contact, person: @person2)
      @role2.update_attributes({followup_status: "attempted_contact"})
      @person3 = Factory(:person)
      @role3 = Factory(:organizational_role, organization: org, role: Role.contact, person: @person3)
      @role3.update_attributes({followup_status: "contacted"})
    end
	
    should "sort by status asc" do
      xhr :get, :index, {:assigned_to => "all", :q =>{:s => "followup_status asc"}}
      assert_equal [@person2.id, @person3.id, @person1.id], assigns(:people).collect(&:id)
      
    end
    
    should "sort by status desc" do
      xhr :get, :index, {:assigned_to => "all", :q =>{:s => "followup_status desc"}}
      assert_equal [@person1.id, @person3.id, @person2.id], assigns(:people).collect(&:id)
    end
  end
end
