require 'test_helper'

class SurveyResponsesControllerTest < ActionController::TestCase
  context "Before logging in" do

    should "redirect on update" do
      @contact = Factory(:person)
      put :update, id: @contact.id
      #assert_redirected_to '/users/sign_in'
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
        assert_not_nil assigns(:title)
        assert_equal assigns(:title), @survey.terminology
      end
      should render_template('thanks')
    end
    
    context "when posting an update with bad parameters" do
      setup do
        @request.host = 'mhub.cc'
        put :update, id: @user.person.id, format: 'mobile', person: {first_name: ''}, keyword: @keyword.keyword
        assert_not_nil assigns(:title)
        assert_equal assigns(:title), @survey.terminology
      end
      should render_template('new')
    end
    
    context "when posting create with missing info" do
      setup do
        @request.host = 'mhub.cc'
        post :create, id: @user.person.id, format: 'mobile', person: {first_name: ''}, keyword: @keyword.keyword
        assert_not_nil assigns(:title)
        assert_equal assigns(:title), @survey.terminology
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
      post :create, { :survey_id => @survey.id, :person => { first_name: "Jane", last_name: "Deer", phone_number: "1234567890" }, :answers => @answer_to_choice.attributes }
      assert_response(:success)
    end
    
=begin
    should "merge people when sent params has an email that is existing in the db" do
      @respondent = Factory.create(:user_no_org_with_facebook)
      Factory.create(:authentication, user: @respondent)
      @email = Factory(:email_address, person: @respondent.person)
      @organization.add_contact(@respondent.person)
      @answer_sheet = Factory(:answer_sheet, survey: @survey, person: @respondent.person)
      @answer_to_choice = Factory(:answer_1, answer_sheet: @answer_sheet, question: @questions.first)
      
      stub_request(:get, "http://api.bit.ly/v3/shorten?apiKey=R_1b6fbe0b4987dc3801ddb9f812d60f84&login=vincentpaca&longUrl=http://local.missionhub.com:7888/people/#{@respondent.person.id}").to_return(:status => 200, :body => "", :headers => {})
      
      post :create, { :survey_id => @survey.id, :person => { first_name: @respondent.person.first_name, last_name: @respondent.person.last_name, phone_number: "1234567890", email: @email.email}, :answers => @answer_to_choice.attributes }
      assert_response(:success)
    end
=end
  end
  
  context "Answerring a survey" do
    setup do
      @user = Factory(:user_with_auxs)  #user with a person object
      sign_in @user
      @organization = Factory(:organization)
      
      @survey = Factory(:survey, organization: @organization)
      @question = Factory(:text_field)
      @survey.questions << @question
      @questions = @survey.questions
      assert_equal(@questions.count, 1)
      
      @survey2 = Factory(:survey, organization: @organization)
    end
    
    should "not create an answer sheet when a surveyee answered just blanks in the survey question fields" do
      assert_difference "AnswerSheet.count", 1 do
        xhr :get, :new, {:survey_id => @survey.id}
      end
      assert_difference "AnswerSheet.count", -1 do
        xhr :put, :update, {:survey_id => @survey.id, :answers => { @question.id => ""}, :id => @user.person.id}
        assert_response(:success)
      end
        
    end
    
    should "not create an answer sheet when a surveyee has just answered a survey without any questions" do
      assert_difference "AnswerSheet.count", 1 do
        xhr :get, :new, {:survey_id => @survey2.id}
      end
      assert_difference "AnswerSheet.count", -1 do
        xhr :put, :update, {:survey_id => @survey2.id, :id => @user.person.id}
        assert_response(:success)
      end
        
    end
    
    should "not create an answer sheet when a surveyee is a new Person and answered just blanks in the survey question fields" do
      assert_no_difference "AnswerSheet.count" do
        xhr :put, :create, {:survey_id => @survey.id, :answers => { @question.id => ""}, :person => {:first_name => "Karl", :last_name => "Pilkington"}}
        assert_response(:success)
      end
        
    end
    
    should "be able to update phone number to correct phone number when first input is wrong" do
      #assert_difference "Person.count" do
        xhr :put, :create, {:survey_id => @survey.id, :person => {:firstName => "Karl", :lastName => "Pilkington", :phone_number => "karl"}}
      #end
      xhr :put, :update, {:survey_id => @survey.id, :id => Person.last.personID, :person => {:phone_number => "123456789"}}
      assert_equal "123456789", Person.last.phone_numbers.first.number
      
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
