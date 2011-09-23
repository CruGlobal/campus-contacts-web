require 'test_helper'

class ContactsControllerTest < ActionController::TestCase
  context "Before logging in" do
    # should "redirect on new" do
    #   get :new, keyword: Factory(:sms_keyword).keyword
    #   assert_redirected_to '/users/sign_in'
    # end
    
    should "redirect on update" do
      @contact = Factory(:person)
      put :update, id: @contact.id
      assert_redirected_to '/users/sign_in'
    end
    
    should "redirect for thanks" do
      get :thanks
      assert_redirected_to '/users/sign_in'
    end
  end
  
  context "After logging in a person with orgs" do
    setup do
      #@user = Factory(:user)
      @user = Factory(:user_with_auxs)  #user with a person object
      sign_in @user
      @keyword = Factory.create(:sms_keyword)
    end
    
    context "creating a new contact manually" do
      should "create a person with only an email address" do
        xhr :post, :create, {"assigned_to" => "all", "dnc" => "", "person" => {"email_address" => {"email" => "test@uscm.org"},"firstName" => "Test","lastName" => "Test",  "phone_number" => {"number" => ""}}}
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
    
    context "new with received_sms_id from mobile" do
      setup do
        @sms = Factory(:sms_session, sms_keyword: @keyword, person: @user.person)
        get :new, received_sms_id: Base62.encode(@sms.id), format: 'mobile'
        @person = assigns(:person) 
      end
    
      should assign_to(:person)
      should respond_with(:success)
      
      should "update person with sms phone number" do
        assert(@person.phone_numbers.detect {|p| p.number_with_country_code == @sms.phone_number}, 'phone number wasn\'t saved')
      end
      should "associate the sms with the person" do
        @sms.reload
        assert(@sms.person == @person, "Sms wasn't assiged to person properly")
      end
    end
    
    context "when posting an update with good parameters from mhub" do
      setup do
        @contact = Factory(:person)
        @request.host = 'mhub.cc' 
        put :update, id: @contact.id, format: 'mobile', keyword: @keyword.keyword
      end
      should render_template('thanks')
    end
    
    context "when posting an update with bad parameters" do
      setup do
        @contact = Factory(:person)
        @request.host = 'mhub.cc'
        put :update, id: @contact.id, format: 'mobile', person: {firstName: ''}, keyword: @keyword.keyword
      end
      should render_template('new')
    end
    
    context "show thanks" do   
      setup do 
        @keywordDB2 = Factory.create(:sms_keyword, keyword: "test2")
        get :thanks, format: 'mobile', keyword: @keywordDB2.keyword
      end
      should "show thanks" do
        assert_response :success, @response.body
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
    
    context "new with received_sms_id from mobile" do
      setup do
        @sms = Factory(:sms_session, sms_keyword: @keyword, person: @user.person)
        get :new, received_sms_id: Base62.encode(@sms.id), format: 'mobile'
        @person = assigns(:person)
      end
    
      should assign_to(:person)
      should respond_with(:success)
      
      should "update person with sms phone number" do
        assert(@person.phone_numbers.detect {|p| p.number_with_country_code == @sms.phone_number}, 'phone number wasn\'t saved')
      end
      should "associate the sms with the person" do
        @sms.reload
        assert(@sms.person == @person, "Sms wasn't assiged to person properly")
      end
    end
    
    context "going to web contact form" do
      setup do
        get :new, keyword: @keyword.keyword
      end
      should respond_with(:success)
      should render_template('new')
      should "not show archived questions" do
        assert_equal(1, assigns(:questions).length)
      end
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
end
