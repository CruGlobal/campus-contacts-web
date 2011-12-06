require 'test_helper'

class SurveyResponsesControllerTest < ActionController::TestCase
  context "Before logging in" do

    should "redirect on update" do
      @contact = Factory(:person)
      put :update, id: @contact.id
      assert_redirected_to '/users/sign_in'
    end
    
  end
  
  
  context "After logging in a person without orgs" do
    setup do
      @user = Factory(:user_no_org)  #user with a person object
      sign_in @user
      @organization = Factory(:organization)
      @keyword = Factory.create(:approved_keyword, organization: @organization)
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
        
    context "when posting an update with good parameters from mhub" do
      setup do
        @request.host = 'mhub.cc' 
        put :update, id: @user.person.id, format: 'mobile', keyword: @keyword.keyword
      end
      should render_template('thanks')
    end
    
    context "when posting an update with bad parameters" do
      setup do
        @request.host = 'mhub.cc'
        put :update, id: @user.person.id, format: 'mobile', person: {firstName: ''}, keyword: @keyword.keyword
      end
      should render_template('new')
    end
    
    context "when posting create with missing info" do
      setup do
        @request.host = 'mhub.cc'
        post :create, id: @user.person.id, format: 'mobile', person: {firstName: ''}, keyword: @keyword.keyword
      end
      should render_template('new')
    end
    
    context "show thanks" do   
      setup do 
        get :thanks, format: 'mobile', keyword: @keyword.keyword
      end
      should "show thanks" do
        assert_response :success, @response.body
      end
    end
    
  end

end
