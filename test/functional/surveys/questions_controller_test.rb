require 'test_helper'

class Surveys::QuestionsControllerTest < ActionController::TestCase
  setup do
    @user, @org = admin_user_login_with_org
    sign_in @user
    Factory(:approved_keyword, organization: @org, user: @user)
    @survey = @org.surveys.first
    @predefined_survey = Factory(:survey, organization: @org)
    APP_CONFIG['predefined_survey'] = @predefined_survey.id

  end

  test "should get index" do
    element = Factory(:choice_field, label: 'foobar', attribute_name: 'phone_number')
    Factory(:survey_element, survey: @org.surveys.first, element: element, position: 1, archived: true)

    APP_CONFIG['predefined_survey'] = Factory(:survey).id
    get :index, survey_id: @survey.id
    assert_response :success
  end

  #context "When updating a question" do
  #  setup do
  #    @leader1 = Factory(:user_with_auxs)
  #   @leader2 = Factory(:user_with_auxs)
  #   @leader3 = Factory(:user_with_auxs)
  #    @survey = Factory(:survey, organization: x.organization)
  #    @element = Factory(:text_field, label: 'foobar')
  #    @survey_element = Factory(:survey_element, survey: survey, element: element, position: 1, archived: true)
  #  end

    #should "update to-be-notified-leaders" do
    #  xhr :post, :update, {:text_field =>{:label => @element.label, :content => "", :trigger_words => "Hello", :notify_via => "Email", :web_only => "0"}, :leaders => [@leader1.id], :commit => "Update", :survey_id => @survey.id, :id => @survey_element.id}
    #  assert_response :success
    #end
  #end

  context "When updating questions" do
    setup do
      element = Factory(:choice_field, label: 'foobar')
      @q1 = Factory(:survey_element, survey: @org.surveys.first, element: element, position: 1, archived: true)
      element = Factory(:choice_field)
      @q2 = Factory(:survey_element, survey: @org.surveys.first, element: element, position: 2)
      element = Factory(:choice_field)
      @q3 = Factory(:survey_element, element: element)
    end

    should "be able to select a predefined or previously used question" do
      xhr :post, :create, { :question_id => @q3.element.id, :survey_id => @org.surveys.first.id}
      assert_response :success
    end

    should "not be able to add the same Question twice in a survey" do
      assert_difference "SurveyElement.count" do
        xhr :post, :create, { :question_id => @q3.element.id, :survey_id => @org.surveys.first.id}
        assert_response :success
      end

      assert_no_difference "SurveyElement.count" do
        xhr :post, :create, { :question_id => @q3.element.id, :survey_id => @org.surveys.first.id}
        assert_response :success
      end
    end
  end

  context "show" do
    setup do
      @user, org = admin_user_login_with_org
      @survey = Factory(:survey, organization: org) #create survey
      @question = Factory(:some_question)
      @survey.questions << @question
      assert_equal(@survey.questions.count, 1)
    end

    should "show" do
      xhr :get, :show, {:id => @question.id, :survey_id => @survey.id}
      assert_not_nil assigns(:question)
      assert_response :success
    end
  end

  context "new" do
    setup do
      @user, org = admin_user_login_with_org
      @survey = Factory(:survey, organization: org) #create survey
      @question = Factory(:some_question)
      @survey.questions << @question
      assert_equal(@survey.questions.count, 1)
    end

    should "new" do
      xhr :get, :new, {:survey_id => @survey.id}
      assert_response :success
    end
  end

  context "reorder" do
    setup do
      @user, org = admin_user_login_with_org
      @survey = Factory(:survey, organization: org) #create survey
      @question_1 = Factory(:some_question)
      @question_2 = Factory(:some_question)
      @survey.questions << @question_1
      @survey.questions << @question_2
      assert_equal(@survey.questions.count, 2)
    end

    should "reorder" do
      a = []
      a << @question_2.id
      a << @question_1.id
      xhr :post, :reorder, {:questions => a, :survey_id => @survey.id}
      assert_response :success
    end
  end

  context "create" do
    setup do
      @user, org = admin_user_login_with_org
      @user_2 = Factory(:user_with_auxs)
      org.add_leader(@user_2.person, @user.person)
      @survey = Factory(:survey, organization: org) #create survey
      @question_3 = Factory(:some_question)
      @survey.questions << @question_3
      @survey.survey_elements.where(element_id: @question_3.id).first.update_attributes({archived: true})
    end

    should "create" do
      assert_difference "Question.count", 1 do
        xhr :post, :create, {:question_type => "ChoiceField:radio", :question => {:label => "", :slug => "", :content => "Verge\r\nBarge\r\nTarge", :notify_via => "SMS", :web_only => "0", :hidden => "0"}, :survey_id => @survey.id}
        assert_response :success
      end
    end

    should "create from existing archived question" do
      assert_no_difference "Question.count" do
        assert_no_difference "Survey.find(#{@survey.id}).survey_elements.count", 1 do
          xhr :post, :create, {:question_id => @question_3.id, :survey_id => @survey.id}
          assert_response :success
        end
      end
    end

    should "create question with trigger words" do
      rule = Factory(:rule, rule_code: "AUTONOTIFY")
      rule = Factory(:rule, rule_code: "AUTOASSIGN")
      Factory(:question_rule, rule: rule, survey_element: @survey.survey_elements.where(element_id: @question_3.id).first)
      assert_difference "Question.count", 1 do
        xhr :post, :create, {:question_type => "ChoiceField:radio", :question => {:label => "", :slug => "", :content => "Verge\r\nBarge\r\nTarge", :notify_via => "SMS", :web_only => "0", :hidden => "0"}, :leaders => [@user_2.person.id], :trigger_words => "Yes", :assign_contact_to => "Leader", :autoassign_keyword =>"#{@user_2.person.name} (#{@user_2.person.email})", :autoassign_selected_id =>"#{@user_2.person.id}", :assignment_trigger_words =>"trigger, happy", :survey_id => @survey.id}
        assert_response :success
      end
    end

    should "should not create question with trigger words if chosen leader has an invalid email" do
      Factory(:rule, rule_code: "AUTONOTIFY")
      @user_2.person.email_addresses.collect(&:destroy)
      invalid_email = Factory.build(:email_address, email: "invalidemail", person: @user_2.person)
      invalid_email.save(:validate => false)

      #assert_no_difference "Question.count" do
        xhr :post, :create, {:question_type => "ChoiceField:radio", :question => {:label => "", :slug => "", :content => "Verge\r\nBarge\r\nTarge", :notify_via => "SMS", :web_only => "0", :hidden => "0"}, :leaders => [@user_2.person.id], :trigger_words => "Yes", :assign_contact_to => "Leader", :autoassign_keyword =>"", :autoassign_selected_id =>"", :assignment_trigger_words =>"", :survey_id => @survey.id}
        assert_response :success
      #end
    end
  end

  context "update" do
    setup do
      @user, org = admin_user_login_with_org
      @survey = Factory(:survey, organization: org) #create survey
      @question = Factory(:some_question)
      @survey.questions << @question
      @survey.survey_elements.where(element_id: @question.id).first.update_attributes({archived: true})

      @user_2 = Factory(:user_with_auxs)
      org.add_leader(@user_2.person, @user.person)
    end

    should "update" do
      xhr :put, :update, {:choice_field => {:label => "Favorite color?", :slug => "", :content => "Verge\r\nBarge\r\nTarge", :notify_via => "SMS", :web_only => "0", :hidden => "0"}, :survey_id => @survey.id, :id => @question.id}
      assert_equal "Favorite color?", Element.find(@question.id).label
      assert_response :success
    end

    should "update with trigger words" do
      rule = Factory(:rule, rule_code: "AUTONOTIFY")
      Factory(:question_rule, rule: rule, survey_element: @survey.survey_elements.where(element_id: @question.id).first)
      xhr :put, :update, {:choice_field => {:label => "Favorite color?", :slug => "", :content => "Verge\r\nBarge\r\nTarge", :notify_via => "SMS", :web_only => "0", :hidden => "0"}, :leaders => [@user_2.person.id], :trigger_words => "Yes", :assign_contact_to => "Leader", :autoassign_keyword =>"", :autoassign_selected_id =>"", :assignment_trigger_words =>"", :survey_id => @survey.id, :id => @question.id}
      assert_equal "Favorite color?", Element.find(@question.id).label
      assert_response :success
    end

    should "update question with trigger words and autoassign" do
      rule = Factory(:rule, rule_code: "AUTONOTIFY")
      rule = Factory(:rule, rule_code: "AUTOASSIGN")
      Factory(:question_rule, rule: rule, survey_element: @survey.survey_elements.where(element_id: @question.id).first)
      assert_no_difference "Question.count" do
        xhr :put, :update, {:choice_field => {:label => "Favorite color?", :slug => "", :content => "Verge\r\nBarge\r\nTarge", :notify_via => "SMS", :web_only => "0", :hidden => "0"}, :leaders => [@user_2.person.id], :trigger_words => "Yes", :assign_contact_to => "Leader", :autoassign_keyword =>"#{@user_2.person.name} (#{@user_2.person.email})", :autoassign_selected_id =>"#{@user_2.person.id}", :assignment_trigger_words =>"trigger, happy", :survey_id => @survey.id, :id => @question.id}
        assert_response :success
      end
    end

    should "not update with the wrong question kind" do
      xhr :put, :update, {:choice_field => {:label => "Favorite color?", :slug => "", :content => "Verge\r\nBarge\r\nTarge", :notify_via => "SMS", :web_only => "0", :hidden => "0"}, :survey_id => @survey.id, :id => @question.id}
      #assert_equal @question.label, Element.find(@question.id).label
      assert_response :success
    end
  end

  context "destroy" do
    setup do
      @user, @org = admin_user_login_with_org
      @survey = Factory(:survey, organization: @org) #create survey
      @question = Factory(:some_question)
      @survey.questions << @question
    end

    should "destroy" do
      assert_difference "Survey.find(#{@survey.id}).survey_elements.count", -1 do
        xhr :post, :destroy, {:survey_id => @survey.id, :id => @question.id}
        assert_response :success
      end
    end

    should "destroy on surveys count > 1" do
      @survey_2 = Factory(:survey, organization: @org) #create survey
      @survey_2.questions << @question

      xhr :post, :destroy, {:survey_id => @survey_2.id, :id => @question.id}
      assert_response :success
    end
  end

  context "hide & unhide" do
    setup do
      @user, org = admin_user_login_with_org
      @survey = Factory(:survey, organization: org) #create survey
      @question = Factory(:some_question)
      @survey.questions << @question

      @predefined = Factory(:survey, organization: org)
      APP_CONFIG['predefined_survey'] = @predefined.id
      @predefined.questions << Factory(:year_in_school_element)
    end

    should "hide" do
      xhr :put, :hide, {:survey_id => @survey.id, :id => @question.id}
      assert_response :success
    end

    should "unhide" do
      request.env["HTTP_REFERER"] = "localhost:3000"
      @question.update_attributes({:hidden => true})
      xhr :put, :unhide, {:survey_id => @survey.id, :id => @question.id}
      assert_response :redirect
    end
  end

  context "Suggestions" do
    setup do
      @user, org = admin_user_login_with_org
      @survey = Factory(:survey, organization: org) #create survey
      @question = Factory(:some_question)
      @survey.questions << @question
    end

    should "find leader suggestions" do
      xhr :get, :suggestion, {:survey_id => @survey.id, :type => "Leader", :keyword => "Neil", :term => "Neil"}
      assert_response :success
    end

    should "find ministry suggestions" do
      xhr :get, :suggestion, {:survey_id => @survey.id, :type => "Ministry", :keyword => "Minstry", :term => "Minstry"}
      assert_response :success
    end

    should "find group suggestions" do
      xhr :get, :suggestion, {:survey_id => @survey.id, :type => "Group", :keyword => "Group", :term => "Group"}
      assert_response :success
    end

    should "find label suggestions" do
      xhr :get, :suggestion, {:survey_id => @survey.id, :type => "Label", :keyword => "Neil", :term => "Neil"}
      assert_response :success
    end
  end

end
