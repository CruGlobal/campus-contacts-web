require 'test_helper'

class ContactsControllerTest < ActionController::TestCase
  context "Before logging in" do
    should "redirect on new" do
      get :new
      assert_redirected_to '/users/sign_in'
    end
    
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
      @keywordDB = Factory.create(:sms_keyword)
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
        @sms = Factory(:received_sms)
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
    
    context "when posting an update with good parameters" do
      setup do
        @contact = Factory(:person)
        put :update, id: @contact.id, format: 'mobile', keyword: @keywordDB.keyword
      end
      should render_template('thanks')
    end
    
    context "when posting an update with bad parameters" do
      setup do
        @contact = Factory(:person)
        put :update, id: @contact.id, format: 'mobile', person: {firstName: ''}, keyword: @keywordDB.keyword
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
      @keyword = Factory.create(:sms_keyword, organization: @organization)
    end
    
    context "on index page" do
      setup do
        get :index
        assert_redirected_to '/wizard'
      end
    end
    
    context "new with received_sms_id from mobile" do
      setup do
        @sms = Factory(:received_sms)
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
    end
  end
end
