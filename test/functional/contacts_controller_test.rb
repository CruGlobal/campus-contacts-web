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
    user1 = Factory(:user_with_auxs)
    user2 = Factory(:user_with_auxs)
    
    user, org = admin_user_login_with_org
    
    Factory(:organizational_role, person: user1.person, organization: org, role: Role.leader)
    Factory(:organizational_role, person: user2.person, organization: org, role: Role.leader)
    
    xhr :post, :send_reminder, { :to => "#{user1.person.id}, #{user2.person.id}" }
    
    assert_equal " ", response.body    
    assert_equal 1, ActionMailer::Base.deliveries.count
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
end
