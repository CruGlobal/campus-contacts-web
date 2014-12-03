require 'test_helper'

class SurveysControllerTest < ActionController::TestCase
  context "Mass Entry - " do
    setup do
      @user, @org = admin_user_login_with_org
      @person = @user.person

      @contact1 = Factory(:person)
      @org.add_contact(@contact1)
      @contact2 = Factory(:person)
      @org.add_contact(@contac2)
      @contact3 = Factory(:person)
      @org.add_contact(@contac3)

      @survey = Factory(:survey, organization: @org)
      @question1 = Factory(:element, label: "Question1", position: 1, object_name: nil, attribute_name: nil)
      @survey.questions << @question1
      @question2 = Factory(:element, label: "Question2", position: 2, object_name: "person", attribute_name: "campus")
      @survey.questions << @question2
      
      @answer_sheet1 = Factory(:answer_sheet, survey: @survey, person: @contact1)
      @answer11 = Factory(:answer, answer_sheet: @answer_sheet1, question: @question1, value: "Random String Value")
      @contact1.update_attribute(:campus, "Campus String Value")
    end
    
    context "mass_entry_save" do
      should "do nothing if no value is present" do
        xhr :post, :mass_entry_save, id: @survey.id
        assert_response :success
      end
      # should "update answer for default question" do
      #   value = {
      #     "id" => @contact1.id.to_s,
      #     "first_name" => "New First Name",
      #     "last_name" => @contact1.last_name
      #   }
      #   data = {"0" => value}
      #   puts data.inspect
      #
      #   xhr :post, :mass_entry_save, id: @survey.id, values: data
      #   assert_response :success
      #   assert_equal "New First Name", @contact1.first_name
      # end
      should "update answer for predefined question" do
        value = {
          "id" => @contact1.id.to_s,
          "#{@question2.id}" => "New Campus String"
        }
        data = {"0" => value}
        
        xhr :post, :mass_entry_save, id: @survey.id, values: data
        assert_response :success
        @contact1.reload
        assert_equal "New Campus String", @contact1.campus
      end
      should "update answer to non-predefined question" do
        value = {
          "id" => @contact1.id.to_s,
          "#{@question1.id}" => "New String Value"
        }
        data = {"0" => value}
        
        xhr :post, :mass_entry_save, id: @survey.id, values: data
        assert_response :success
        assert_equal "New String Value", @answer_sheet1.answers.where(question_id: @question1.id).first.value.to_s
      end
    end
    
    context "mass_entry_data" do
      should "return headers correctly" do
        get :mass_entry_data, id: @survey.id
        json = JSON.parse(response.body)
        headers = json["headers"]

        assert_response :success
        assert_equal 5, headers.count
        assert_equal ["First Name", "Last Name", "Phone Number", "Question1", "Question2"], headers
      end
      
      should "return settings correctly" do
        get :mass_entry_data, id: @survey.id
        json = JSON.parse(response.body)
        settings = json["settings"]

        assert_response :success
        settings.each do |setting|
          if ['id','first_name','last_name','phone_number',@question2.id].include?(setting['data'])
            assert setting['readOnly']
          else
            assert !setting['readOnly']
          end
        end
      end
      
      should "return data correctly" do
        get :mass_entry_data, id: @survey.id
        json = JSON.parse(response.body)
        data = json["data"]

        assert_response :success
        data.each do |d|
          if d["id"] == @contact1.id
            assert_equal @contact1.first_name, d["first_name"]
            assert_equal @contact1.last_name, d["last_name"]
            assert_equal @answer11.value, d[@question1.id.to_s]
            assert_equal @contact1.campus, d[@question2.id.to_s] # Answer to Predefined Question
          end
        end
      end
    end
  end
  
  context "Before logging in" do
    should "redirect on to mhub from non-mhub" do
      @request.host = 'missionhub.com'
      @survey = Factory(:survey)
      get :start, id: @survey.id
      assert_redirected_to "https://mhub.cc:80/surveys/#{@survey.id}/start"
    end

    should "redirect to sign out" do
      @request.host = 'mhub.cc'
      @survey = Factory(:survey)
      get :start, id: @survey.id
      assert_redirected_to "https://mhub.cc/sign_out?next=https%3A%2F%2Fmhub.cc%2Fs%2F#{@survey.id}"
    end

    context "start survey no matter what the login option" do
      setup do
        @request.host = "missionhub.com"
      end

      should "redirect to mhub when login option is 0" do
        @survey = Factory(:survey, login_option: 0)
        get :start, id: @survey.id
        assert_redirected_to "surveys://mhub.cc:80/surveys/#{@survey.id}/start"
      end

      should "redirect to mhub when login option is 1" do
        @survey = Factory(:survey, login_option: 1)
        get :start, id: @survey.id
        assert_redirected_to "https://mhub.cc:80/surveys/#{@survey.id}/start"
      end

      should "redirect to mhub when login option is 2" do
        @survey = Factory(:survey, login_option: 0)
        get :start, id: @survey.id
        assert_redirected_to "https://mhub.cc:80/surveys/#{@survey.id}/start"
      end

      should "redirect to mhub when login option is 3" do
        @survey = Factory(:survey, login_option: 3)
        get :start, id: @survey.id
        assert_redirected_to "https://mhub.cc:80/surveys/#{@survey.id}/start"
      end

      should "stop" do
        get :stop
        assert_response :redirect
        assert_equal nil, cookies[:survey_mode]
        assert_equal nil, cookies[:keyword]
        assert_equal nil, cookies[:survey_id]
      end
    end
  end

  should "get admin index" do
    @user, @org = admin_user_login_with_org
    get :index_admin
    assert_not_nil assigns(:organization)
  end

  should "get index" do
    @user, @org = admin_user_login_with_org
    get :index
    assert_not_nil assigns(:organization)
  end

  should "render 404 if no user is logged in" do
    get :index
    assert_response :missing
  end

  test "destroy" do
    request.env["HTTP_REFERER"] = "localhost:3000"
    @user, @org = admin_user_login_with_org
    keyword = Factory(:approved_keyword, user: @user, organization: @org)
    assert_equal 1, @org.surveys.count
    post :destroy, { :id => @org.surveys.first.id }
    assert_equal 0, @org.surveys.count
  end

  test "update" do
    @user, @org = admin_user_login_with_org
    keyword = Factory(:approved_keyword, user: @user, organization: @org)
    put :update, { :id => @org.surveys.first.id, :survey => { :title => "wat" } }
    assert_response :redirect
    assert_equal "wat", @org.surveys.first.title
  end

  test "update fail" do
    @user, @org = admin_user_login_with_org
    keyword = Factory(:approved_keyword, user: @user, organization: @org)
    put :update, { :id => @org.surveys.first.id, :survey => { :title => "" } }
    assert_template :edit
  end

  test "create" do
    @user, @org = admin_user_login_with_org
    post :create, { :survey => {:title => "wat", :post_survey_message => "Yeah!", :login_option => 0 } }
    assert_response :redirect
    assert_equal 1, @org.surveys.count
    assert_equal "wat", @org.surveys.first.title
  end

  test "create fail" do
    @user, @org = admin_user_login_with_org

    assert_no_difference "Survey.count" do
      post :create, { :survey => { } }
    end
  end
end
