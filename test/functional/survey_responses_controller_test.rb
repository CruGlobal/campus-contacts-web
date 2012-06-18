require 'test_helper'

class SurveyResponsesControllerTest < ActionController::TestCase
  context "Before logging in" do

    should "redirect on update" do
      @contact = Factory(:person)
      put :update, id: @contact.id
      assert_redirected_to '/users/sign_in'
    end
    
  end
  
  context "Redirect to correct login option" do
    setup do
      @organization = Factory(:organization)
      @keyword = Factory.create(:approved_keyword, organization: @organization)
      
      @survey0 = Factory.create(:survey, login_option: 0)
      @survey1 = Factory.create(:survey, login_option: 1)
      @survey2 = Factory.create(:survey, login_option: 2)
      @survey3 = Factory.create(:survey, login_option: 3)
    end
    
    should "redirect to sign in if login option is 0" do
      get :new, keyword: @keyword.keyword, survey: @survey0.id
      assert_redirected_to "/users/sign_in"
    end
    
    should "redirect to sign in if login option is 1" do
      get :new, keyword: @keyword.keyword, survey: @survey1.id
      assert_redirected_to "/users/sign_in"
    end
    
    should "redirect to sign in if login option is 2" do
      get :new, keyword: @keyword.keyword, survey: @survey2.id
      assert_redirected_to "/users/sign_in"
    end
    
    should "redirect to sign in if login option is 3" do
      get :new, keyword: @keyword.keyword, survey: @survey3.id
      assert_redirected_to "/users/sign_in"
    end
  end
  
  context "After logging in a person without orgs" do
    setup do
      @user = Factory(:user_no_org)  #user with a person object
      sign_in @user
      @organization = Factory(:organization)
      @survey = Factory(:survey)
      @keyword = Factory.create(:approved_keyword, organization: @organization, survey: @survey)
      
      element = Factory(:choice_field, label: 'foobar')
      q1 = Factory(:survey_element, survey: @survey, element: element, position: 1, archived: true)
      element = Factory(:choice_field)
      q2 = Factory(:survey_element, survey: @survey, element: element, position: 2)
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
        assert_equal(1, assigns(:survey).questions.length)
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
  
  context "Answering a survey with notifications" do
    setup do
      @user = Factory(:user_with_auxs)  #user with a person object
      sign_in @user
      @organization = Factory(:organization)
      
      @survey = Factory(:survey, organization: @organization)
      @keyword = Factory(:approved_keyword, organization: @organization, survey: @survey)
      @notify_q = Factory(:choice_field, notify_via: "Both", trigger_words: "Jesus")
      @survey.questions << @notify_q
      @questions = @survey.questions
      assert_equal(@questions.count, 1)
    end
    
    should "respond success when answering survey" do
      @respondent = Factory.create(:user_no_org_with_facebook)
      Factory.create(:authentication, user: @respondent)
      @organization.add_contact(@respondent.person)
      @answer_sheet = Factory(:answer_sheet, survey: @survey, person: @respondent.person)
      @answer_to_choice = Factory(:answer_1, answer_sheet: @answer_sheet, question: @questions.first)
      
      post :create, { :survey_id => @survey.id, :person => { firstName: "Jane", lastName: "Deer", phone_number: "1234567890" }, :answers => @answer_to_choice.attributes }
      assert_response(:success)
    end
    
  end

  test "show" do
    @user, @org = admin_user_login_with_org
    get :show, { :id => @user.person.id }
    assert_response :success
    assert_not_nil assigns(:person)
  end
  
  test "edit" do
    @user, @org = admin_user_login_with_org
    get :edit, { :id => @user.person.id }
    assert_response :success
    assert_not_nil assigns(:person)
  end
end
