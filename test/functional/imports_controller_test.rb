require 'test_helper'

class ImportsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    #assert_response :success
  end

  test "should get show" do
    get :show
    #assert_response :success
  end

  test "should get new" do
    @user, @org = admin_user_login_with_org
    get :new
    assert_response :success
  end

  test "should download sample contacts csv" do
    @user, @org = admin_user_login_with_org
    get :download_sample_contacts_csv
  end

  context "Adding survey questions" do
    setup do
      @user, @organization = admin_user_login_with_org
      @survey = Factory(:survey, organization: @organization)
    end

    should "add question for an existing survey" do
      xhr :get, :create_survey_question, {select_survey_field: @survey.id, question_category: "TextField:short", question: "This is a sample question", question_id: ''}
      assert_equal assigns(:question), Element.last
      assert_equal SurveyElement.last.survey, @survey
      assert_equal SurveyElement.last.question.label, 'This is a sample question'
    end

    should "create a new survey" do
      xhr :get, :create_survey_question, {create_survey_toggle: 'new_survey', survey_name_field: 'New Survey for Testing', question_category: "ChoiceField:radio", question: "What is your gender?", options: 'Male\r\nFemale', question_id: ''}
      assert_equal SurveyElement.last.question.label, 'What is your gender?'
      assert_equal SurveyElement.last.survey.title, 'New Survey for Testing'
    end
  end

  context "Updating survey questions" do
    setup do
      @user, @organization = admin_user_login_with_org
      @survey = Factory(:survey, organization: @organization)
      @question = Factory(:choice_field, label: 'This is the original question', content: 'Male\r\nFemale')
      Factory(:survey_element, survey: @survey, element: @question)
    end

    should "change the question" do
      assert_equal Element.find(@question.id).content, 'Male\r\nFemale'
      assert_equal Element.find(@question.id).label, "This is the original question"

      xhr :get, :create_survey_question, {question: 'This is the revised question', options: 'Male\r\nFemale\r\nOther', question_id: @question.id}

      assert_equal Element.find(@question.id).label, "This is the revised question"
      assert_equal Element.find(@question.id).content, 'Male\r\nFemale\r\nOther'
    end
  end

  context "Importing contacts" do
    setup do
      stub_request(:put, /https:\/\/s3\.amazonaws\.com\/.*\/mh\/imports\/uploads\/.*/)

      @user, @organization = admin_user_login_with_org

      @survey = Factory(:survey, organization: @organization, id: 2)
      @first_name_element = Factory(:first_name_element)
      @last_name_element = Factory(:last_name_element)
      @email_element = Factory(:email_element)
      @phone_element = Factory(:phone_element)
      @first_name_question = Factory(:survey_element, survey: @survey, element: @first_name_element, position: 1, archived: true)
      @last_name_question = Factory(:survey_element, survey: @survey, element: @last_name_element, position: 2, archived: true)
      @email_question = Factory(:survey_element, survey: @survey, element: @email_element, position: 3, archived: true)
      @phone_question = Factory(:survey_element, survey: @survey, element: @phone_element, position: 4, archived: true)

      @default_role = Factory(:role, organization: @organization)

      @survey2 = Factory(:survey, organization: @organization)
      @question = Factory(:some_question)
      @survey2.questions << @question

      APP_CONFIG['predefined_survey'] = 2
    end

    should "successfully create an import and upload contact" do
      stub_request(:get, /https:\/\/s3\.amazonaws\.com\/.*\/mh\/imports\/uploads\/.*/).
        to_return(body: File.new(Rails.root.join("test/fixtures/contacts_upload_csv/sample_import_1.csv")), status: 200)
      assert_difference "Person.count" do
        contacts_file = File.open(Rails.root.join("test/fixtures/contacts_upload_csv/sample_import_1.csv"))
        file = Rack::Test::UploadedFile.new(contacts_file, "application/csv")
        post :create, { :import => { :upload => file } }
        assert_response :redirect
        post :update, { :import => { :header_mappings => {"0" => @first_name_element.id, "1" => @last_name_element.id, "2" => @email_element.id} }, :id => Import.first.id}
        assert_response :redirect
        post :import, { :use_labels => "0", :id => Import.first.id}
        Import.last.do_import([])
      end
    end

    should "should send emails after importing contacts" do
      stub_request(:get, /https:\/\/s3\.amazonaws\.com\/.*\/mh\/imports\/uploads\/.*/).
        to_return(body: File.new(Rails.root.join("test/fixtures/contacts_upload_csv/sample_import_1.csv")), status: 200)
      assert_difference "Person.count" do
        contacts_file = File.open(Rails.root.join("test/fixtures/contacts_upload_csv/sample_import_1.csv"))
        file = Rack::Test::UploadedFile.new(contacts_file, "application/csv")
        post :create, { :import => { :upload => file } }
        assert_response :redirect
        post :update, { :import => { :header_mappings => {"0" => @first_name_element.id, "1" => @last_name_element.id, "2" => @email_element.id} }, :id => Import.first.id}
        assert_response :redirect
        post :import, { :use_labels => "0", :id => Import.first.id}

        # Send email to the uploader
        assert_difference('ActionMailer::Base.deliveries.size', 1) do
          Import.last.do_import([])
        end
      end
    end

    should "should send emails after importing leaders" do
      stub_request(:get, /https:\/\/s3\.amazonaws\.com\/.*\/mh\/imports\/uploads\/.*/).
        to_return(body: File.new(Rails.root.join("test/fixtures/contacts_upload_csv/sample_import_1.csv")), status: 200)
      assert_difference "Person.count" do
        contacts_file = File.open(Rails.root.join("test/fixtures/contacts_upload_csv/sample_import_1.csv"))
        file = Rack::Test::UploadedFile.new(contacts_file, "application/csv")
        post :create, { :import => { :upload => file } }
        assert_response :redirect
        post :update, { :import => { :header_mappings => {"0" => @first_name_element.id, "1" => @last_name_element.id, "2" => @email_element.id} }, :id => Import.first.id}
        assert_response :redirect
        post :import, { :use_labels => "0", :id => Import.first.id}

        # Send email to imported leader and to the uploader
        assert_difference('ActionMailer::Base.deliveries.size', 2) do
          Import.last.do_import([Role::LEADER_ID])
        end
      end
    end

    should "create new survey and question for unmatched header" do
      stub_request(:get, /https:\/\/s3\.amazonaws\.com\/.*\/mh\/imports\/uploads\/.*/).
        to_return(body: File.new(Rails.root.join("test/fixtures/contacts_upload_csv/sample_import_1.csv")), status: 200)
      contacts_file = File.open(Rails.root.join("test/fixtures/contacts_upload_csv/sample_import_1.csv"))
      file = Rack::Test::UploadedFile.new(contacts_file, "application/csv")
      post :create, { :import => { :upload => file } }
      assert_response :redirect
      post :update, { :import => { :header_mappings => {"0" => @first_name_element.id, "1" => @last_name_element.id, "2" => ""} }, :id => Import.first.id}
      assert_equal "Import-#{assigns(:import).created_at.strftime('%Y-%m-%d')}", Survey.last.title
      assert_equal assigns(:import).headers[2], Element.last.label
    end

    should "unsuccesfully create an import if file is empty" do
      stub_request(:get, /https:\/\/s3\.amazonaws\.com\/.*\/mh\/imports\/uploads\/.*/).
        to_return(body: File.new(Rails.root.join("test/fixtures/contacts_upload_csv/sample_import_blank.csv")), status: 200)
      import_count = Import.count
      contacts_file = File.open(Rails.root.join("test/fixtures/contacts_upload_csv/sample_import_blank.csv"))
      file = Rack::Test::UploadedFile.new(contacts_file, "application/csv")
      post :create, { :import => { :upload => file } }
      assert_response :success
      assert_equal Import.count, import_count
    end

    should "unsuccesfully create an import if headers (row 1) are not present" do
      stub_request(:get, /https:\/\/s3\.amazonaws\.com\/.*\/mh\/imports\/uploads\/.*/).
        to_return(body: File.new(Rails.root.join("test/fixtures/contacts_upload_csv/sample_import_2.csv")), status: 200)
      import_count = Import.count
      contacts_file = File.open(Rails.root.join("test/fixtures/contacts_upload_csv/sample_import_2.csv"))
      file = Rack::Test::UploadedFile.new(contacts_file, "application/csv")
      post :create, { :import => { :upload => file } }
      assert_response :success
      assert_equal Import.count, import_count
    end

    should "unsuccesfully create an import if one of the headers is blank" do
      stub_request(:get, /https:\/\/s3\.amazonaws\.com\/.*\/mh\/imports\/uploads\/.*/).
        to_return(body: File.new(Rails.root.join("test/fixtures/contacts_upload_csv/sample_import_3.csv")), status: 200)
      import_count = Import.count
      contacts_file = File.open(Rails.root.join("test/fixtures/contacts_upload_csv/sample_import_3.csv"))
      file = Rack::Test::UploadedFile.new(contacts_file, "application/csv")
      post :create, { :import => { :upload => file } }
      assert_response :success
      assert_equal Import.count, import_count
    end

    should "update the header_mappings and redirect" do
      stub_request(:get, /https:\/\/s3\.amazonaws\.com\/.*\/mh\/imports\/uploads\/.*/).
        to_return(body: File.new(Rails.root.join("test/fixtures/contacts_upload_csv/sample_import_1.csv")), status: 200)
      contacts_file = File.open(Rails.root.join("test/fixtures/contacts_upload_csv/sample_import_1.csv"))
      file = Rack::Test::UploadedFile.new(contacts_file, "application/csv")
      post :create, { :import => { :upload => file } }
      assert_response :redirect
      post :update, { :import => { :header_mappings => {"0" => @first_name_element.id, "1" => @last_name_element.id, "2" => @email_element.id} }, :id => Import.first.id}
      Import.last.do_import([])
      assert_equal Import.first.header_mappings['0'].to_i, @first_name_element.id
      assert_equal Import.first.header_mappings['1'].to_i, @last_name_element.id
      assert_equal Import.first.header_mappings['2'].to_i, @email_element.id
      assert_response :redirect
    end

    should "upload & import contacts if use_labels is false" do
      stub_request(:get, /https:\/\/s3\.amazonaws\.com\/.*\/mh\/imports\/uploads\/.*/).
        to_return(body: File.new(Rails.root.join("test/fixtures/contacts_upload_csv/sample_import_1.csv")), status: 200)
      contacts_file = File.open(Rails.root.join("test/fixtures/contacts_upload_csv/sample_import_1.csv"))
      file = Rack::Test::UploadedFile.new(contacts_file, "application/csv")
      post :create, { :import => { :upload => file } }
      assert_response :redirect

      post :update, { :import => { :header_mappings => {"0" => @first_name_element.id, "1" => @last_name_element.id, "2" => @email_element.id} }, :id => Import.first.id}
      assert_equal Import.first.header_mappings['0'].to_i, @first_name_element.id
      assert_equal Import.first.header_mappings['1'].to_i, @last_name_element.id
      assert_equal Import.first.header_mappings['2'].to_i, @email_element.id
      person_count  = Person.count

      assert_response :redirect
      # "use_labels"=>"1", "labels"=>["0", "5", "145"], "new_label_field"=>"", "commit"=>"Import Now", "id"=>"13"
      post :import, { :use_labels => "0", :id => Import.first.id}
      Import.first.do_import([])
      assert_equal Person.count, person_count + 1
    end

    should "upload & use existing label & import contacts if use_labels is true" do
      stub_request(:get, /https:\/\/s3\.amazonaws\.com\/.*\/mh\/imports\/uploads\/.*/).
        to_return(body: File.new(Rails.root.join("test/fixtures/contacts_upload_csv/sample_import_1.csv")), status: 200)
      contacts_file = File.open(Rails.root.join("test/fixtures/contacts_upload_csv/sample_import_1.csv"))
      file = Rack::Test::UploadedFile.new(contacts_file, "application/csv")
      post :create, { :import => { :upload => file } }
      assert_response :redirect

      post :update, { :import => { :header_mappings => {"0" => @first_name_element.id, "1" => @last_name_element.id, "2" => @email_element.id} }, :id => Import.first.id}
      assert_equal Import.first.header_mappings['0'].to_i, @first_name_element.id
      assert_equal Import.first.header_mappings['1'].to_i, @last_name_element.id
      assert_equal Import.first.header_mappings['2'].to_i, @email_element.id
      person_count  = Person.count
      assert_response :redirect
      post :import, { :use_labels => "1", :id => Import.first.id, :labels => [@default_role.id]}
      Import.last.do_import([@default_role.id])
      assert_equal Person.count, person_count + 1
      new_person = Person.last
      assert new_person.organizational_roles.exists?(role_id: @default_role.id), 'imported person should have specified role'
      assert_response :redirect
    end

    should "upload & create default label & import contacts if use_labels is true" do
      stub_request(:get, /https:\/\/s3\.amazonaws\.com\/.*\/mh\/imports\/uploads\/.*/).
        to_return(body: File.new(Rails.root.join("test/fixtures/contacts_upload_csv/sample_import_1.csv")), status: 200)
      contacts_file = File.open(Rails.root.join("test/fixtures/contacts_upload_csv/sample_import_1.csv"))
      file = Rack::Test::UploadedFile.new(contacts_file, "application/csv")
      post :create, { :import => { :upload => file } }
      assert_response :redirect

      post :update, { :import => { :header_mappings => {"0" => @first_name_element.id, "1" => @last_name_element.id, "2" => @email_element.id} }, :id => Import.first.id}
      assert_equal Import.first.header_mappings['0'].to_i, @first_name_element.id
      assert_equal Import.first.header_mappings['1'].to_i, @last_name_element.id
      assert_equal Import.first.header_mappings['2'].to_i, @email_element.id
      person_count  = Person.count
      assert_response :redirect

      post :import, { :use_labels => "1", :id => Import.first.id, :labels => [0]}
      Import.first.do_import([0])
      assert_equal Person.count, person_count + 1
      new_person = Person.last
      new_role = Role.find_by_name(Import.first.label_name)
      assert new_person.organizational_roles.exists?(role_id: new_role.id), 'imported person should have the default role'
      assert_response :redirect
    end

    should "succesfully create an import and unsuccesfully upload contact because first_name heading is not specified by the user" do
      stub_request(:get, /https:\/\/s3\.amazonaws\.com\/.*\/mh\/imports\/uploads\/.*/).
        to_return(body: File.new(Rails.root.join("test/fixtures/contacts_upload_csv/sample_import_1.csv")), status: 200)
      person_count  = Person.count
      contacts_file = File.open(Rails.root.join("test/fixtures/contacts_upload_csv/sample_import_1.csv"))
      file = Rack::Test::UploadedFile.new(contacts_file, "application/csv")
      post :create, { :import => { :upload => file } }
      assert_response :redirect

      post :update, { :import => { :header_mappings => {"0" => @last_name_element.id, "1" => @email_element.id} }, :id => Import.first.id}
      Import.last.do_import([])
      assert_equal Person.count, person_count, "contact still uploaded despite there is no first_name header, which is required, specified by the user"
    end

    should "successfully create an import but unsuccesfully upload a contact if one of the emails is invalid" do
      stub_request(:get, /https:\/\/s3\.amazonaws\.com\/.*\/mh\/imports\/uploads\/.*/).
        to_return(body: File.new(Rails.root.join("test/fixtures/contacts_upload_csv/sample_import_4.csv")), status: 200)
      person_count  = Person.count
      contacts_file = File.open(Rails.root.join("test/fixtures/contacts_upload_csv/sample_import_4.csv"))
      file = Rack::Test::UploadedFile.new(contacts_file, "application/csv")
      post :create, { :import => { :upload => file } }
      assert_response :redirect

      post :update, { :import => { :header_mappings => {"0" => @first_name_element.id, "1" => @last_name_element.id, "2" => @phone_element.id, "3" => @email_element.id} }, :id => Import.first.id}
      Import.first.do_import([])
      assert_equal Person.count, person_count
    end

    should "successfully create an import but unsuccesfully upload a contact if one of the phone numbers is invalid" do
      stub_request(:get, /https:\/\/s3\.amazonaws\.com\/.*\/mh\/imports\/uploads\/.*/).
        to_return(body: File.new(Rails.root.join("test/fixtures/contacts_upload_csv/sample_import_5.csv")), status: 200)
      person_count  = Person.count
      contacts_file = File.open(Rails.root.join("test/fixtures/contacts_upload_csv/sample_import_5.csv"))
      file = Rack::Test::UploadedFile.new(contacts_file, "application/csv")
      post :create, { :import => { :upload => file } }
      assert_response :redirect

      post :update, { :import => { :header_mappings => {"0" => @first_name_element.id, "1" => @last_name_element.id, "2" => @phone_element.id, "3" => @email_element.id} }, :id => Import.first.id}
      Import.last.do_import([])
      assert_equal Person.count, person_count
    end

    should "successfully create an import but unsuccesfully upload a contact if at least two of the headers has the same selected person attribute/survey question" do
      stub_request(:get, /https:\/\/s3\.amazonaws\.com\/.*\/mh\/imports\/uploads\/.*/).
        to_return(body: File.new(Rails.root.join("test/fixtures/contacts_upload_csv/sample_import_5.csv")), status: 200)
      person_count  = Person.count
      contacts_file = File.open(Rails.root.join("test/fixtures/contacts_upload_csv/sample_import_5.csv"))
      file = Rack::Test::UploadedFile.new(contacts_file, "application/csv")
      post :create, { :import => { :upload => file } }
      assert_response :redirect

      post :update, { :import => { :header_mappings => {"0" => @first_name_element.id, "1" => @first_name_element.id, "2" => @phone_element.id, "3" => @email_element.id} }, :id => Import.first.id}
      Import.last.do_import([])
      assert_equal Person.count, person_count
    end

    should "unsuccessfully create an import if file is invalid" do
      stub_request(:get, /https:\/\/s3\.amazonaws\.com\/.*\/mh\/imports\/uploads\/.*/).
        to_return(body: File.new(Rails.root.join("test/fixtures/contacts_upload_csv/sample_import_6.ods")), status: 200)
      contacts_file = File.open(Rails.root.join("test/fixtures/contacts_upload_csv/sample_import_6.ods"))
      file = Rack::Test::UploadedFile.new(contacts_file, "application/csv")
      post :create, { :import => { :upload => file } }
    end

=begin
    should "unsuccessfully create an import if file is not existing" do
      stub_request(:get, /https:\/\/s3\.amazonaws\.com\/.*\/mh\/imports\/uploads\/.*/).
        to_return(body: File.new(Rails.root.join("test/fixtures/contacts_upload_csv/sample_import_0.csv")), status: 200)
      contacts_file = File.open(Rails.root.join("test/fixtures/contacts_upload_csv/sample_import_0.csv"))
      file = Rack::Test::UploadedFile.new(contacts_file, "application/csv")
      post :create, { :import => { :upload => file } }
    end
=end

    should "edit import file" do
      stub_request(:get, /https:\/\/s3\.amazonaws\.com\/.*\/mh\/imports\/uploads\/.*/).
        to_return(body: File.new(Rails.root.join("test/fixtures/contacts_upload_csv/sample_import_1.csv")), status: 200)

      contacts_file = File.open(Rails.root.join("test/fixtures/contacts_upload_csv/sample_import_1.csv"))
      file = Rack::Test::UploadedFile.new(contacts_file, "application/csv")
      predefined_survey = Factory(:survey)
      APP_CONFIG['predefined_survey'] = predefined_survey.id
      post :create, { :import => { :upload => file } }
      post :edit, { :id => Import.last.id }
      assert_template "imports/edit"
    end


=begin
    should "successfully destroy an import" do
      stub_request(:get, /https:\/\/s3\.amazonaws\.com\/.*\/mh\/imports\/uploads\/.*/).to_return(body: File.new(Rails.root.join("test/fixtures/contacts_upload_csv/sample_import_1.csv")), status: 200)

      contacts_file = File.open(Rails.root.join("test/fixtures/contacts_upload_csv/sample_import_1.csv"))
      file = Rack::Test::UploadedFile.new(contacts_file, "application/csv")
      post :create, { :import => { :upload => file } }

      stub_request(:delete, /https:\/\/s3\.amazonaws\.com\/.*\/mh\/imports\/uploads\/.*/).to_return(body: File.new(Rails.root.join("test/fixtures/contacts_upload_csv/sample_import_1.csv")), status: 200)
      post :destroy, {:id => Import.last.id}
      assert_response :redirect
    end
=end

    should "successfully create an import and upload contact with non-predefined surveys" do
      stub_request(:get, /https:\/\/s3\.amazonaws\.com\/.*\/mh\/imports\/uploads\/.*/).
        to_return(body: File.new(Rails.root.join("test/fixtures/contacts_upload_csv/sample_import_7.csv")), status: 200)

        contacts_file = File.open(Rails.root.join("test/fixtures/contacts_upload_csv/sample_import_7.csv"))
        file = Rack::Test::UploadedFile.new(contacts_file, "application/csv")
        post :create, { :import => { :upload => file } }
        assert_response :redirect

        assert_difference "AnswerSheet.count", 1 do
          post :update, { :import => { :header_mappings => {"0" => @first_name_element.id, "1" => @last_name_element.id, "3" => @email_element.id, "4" => @question.id} }, :id => Import.first.id}
          post :import, { :use_labels => "0", :id => Import.first.id}
          Import.last.do_import([])
          assert_equal Person.last.answer_sheets.first.answers.first.value, "I just met you"
        end
    end

    should "successfully create an import and redirect to labels" do
      stub_request(:get, /https:\/\/s3\.amazonaws\.com\/.*\/mh\/imports\/uploads\/.*/).
        to_return(body: File.new(Rails.root.join("test/fixtures/contacts_upload_csv/sample_import_7.csv")), status: 200)

        contacts_file = File.open(Rails.root.join("test/fixtures/contacts_upload_csv/sample_import_7.csv"))
        file = Rack::Test::UploadedFile.new(contacts_file, "application/csv")
        post :create, { :import => { :upload => file } }
        assert_response :redirect

        post :update, { :import => { :header_mappings => {"0" => @first_name_element.id, "1" => @last_name_element.id, "3" => @email_element.id, "4" => @question.id} }, :id => Import.first.id}
        assert_redirected_to "/imports/#{Import.last.id}/labels"
        get :labels, {:id => Import.last.id}
    end
  end
end
