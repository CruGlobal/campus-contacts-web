require 'test_helper'

class ContactsControllerTest < ActionController::TestCase
  context "Before logging in" do
    should "redirect on update" do
      @contact = Factory(:person)
      put :update, id: @contact.id
      assert_redirected_to '/users/sign_in'
    end
  end
  
  context "After logging in a person with orgs" do
    setup do
      @user = Factory(:user_with_auxs)  #user with a person object
      sign_in @user
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
  
  context "Importing contacts" do
    setup do
      @user = Factory(:user_with_auxs)  #user with a person object
      sign_in @user
    end
    
    should "successfully import contacts" do
      contacts_file = File.open(Rails.root.join("test/fixtures/sample_contacts.csv"))
      file = Rack::Test::UploadedFile.new(contacts_file, "application/csv")
      post :csv_import, { :dump => { :file => file } }
      assert_response(:success)
    end
  end
end
