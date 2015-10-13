require 'test_helper'

class ImportsControllerTest < ActionController::TestCase
  S3_URL_REGEXP = /https:\/\/s3\.amazonaws\.com\/.*\/mh\/imports\/uploads\/.*/

  def stub_s3_with_file(filename)
    stub_request(:get, S3_URL_REGEXP)
      .to_return(body: File.new(Rails.root.join("test/fixtures/contacts_upload_csv/#{filename}")), status: 200)
  end

  def post_create_with_file(filename)
    contacts_file = File.open(Rails.root.join("test/fixtures/contacts_upload_csv/#{filename}"))
    file = Rack::Test::UploadedFile.new(contacts_file, 'application/csv')
    post :create, import: { upload: file }
  end

  test 'should get new' do
    @user, @org = admin_user_login_with_org
    get :new
    assert_response :success
  end

  test 'should download sample contacts csv' do
    @user, @org = admin_user_login_with_org
    get :download_sample_contacts_csv
  end

  context 'Adding survey questions' do
    setup do
      @user, @organization = admin_user_login_with_org
      @survey = FactoryGirl.create(:survey, organization: @organization)
    end

    should 'add question for an existing survey' do
      xhr :get, :create_survey_question, select_survey_field: @survey.id, question_category: 'TextField:short', question: 'This is a sample question', question_id: '', id: 1
      assert_equal assigns(:question), Element.last
      assert_equal SurveyElement.last.survey, @survey
      assert_equal SurveyElement.last.question.label, 'This is a sample question'
    end

    should 'create a new survey' do
      xhr :get, :create_survey_question,
          create_survey_toggle: 'new_survey', survey_name_field: 'New Survey for Testing',
          question_category: 'ChoiceField:radio', question: 'What is your gender?',
          options: 'Male\r\nFemale', question_id: '', id: 1
      assert_equal SurveyElement.last.question.label, 'What is your gender?'
      assert_equal SurveyElement.last.survey.title, 'New Survey for Testing'
    end
  end

  context 'Updating survey questions' do
    setup do
      @user, @organization = admin_user_login_with_org
      @survey = FactoryGirl.create(:survey, organization: @organization)
      @question = FactoryGirl.create(:choice_field, label: 'This is the original question', content: 'Male\r\nFemale')
      FactoryGirl.create(:survey_element, survey: @survey, element: @question)
    end

    should 'change the question' do
      assert_equal Element.find(@question.id).content, 'Male\r\nFemale'
      assert_equal Element.find(@question.id).label, 'This is the original question'

      xhr :get, :create_survey_question, question: 'This is the revised question', options: 'Male\r\nFemale\r\nOther', question_id: @question.id, id: '1'

      assert_equal Element.find(@question.id).label, 'This is the revised question'
      assert_equal Element.find(@question.id).content, 'Male\r\nFemale\r\nOther'
    end
  end

  context 'Importing contacts' do
    setup do
      stub_request(:put, S3_URL_REGEXP)

      @user, @organization = admin_user_login_with_org
      FactoryGirl.create(:email_address, email: 'user@email.com', person: @user.person)
      @user.person.reload

      @survey = FactoryGirl.create(:survey, organization: @organization, id: 2)
      fn_question = FactoryGirl.create(:first_name_element)
      ln_question = FactoryGirl.create(:last_name_element)
      @email_question = FactoryGirl.create(:email_element)
      phone_question = FactoryGirl.create(:phone_element)
      @first_name_element = FactoryGirl.create(:survey_element, survey: @survey, element: fn_question, position: 1, archived: true)
      @last_name_element = FactoryGirl.create(:survey_element, survey: @survey, element: ln_question, position: 2, archived: true)
      @email_element = FactoryGirl.create(:survey_element, survey: @survey, element: @email_question, position: 3, archived: true)
      @phone_element = FactoryGirl.create(:survey_element, survey: @survey, element: phone_question, position: 4, archived: true)

      @default_label = FactoryGirl.create(:label, organization: @organization)

      @survey2 = FactoryGirl.create(:survey, organization: @organization)
      @question = FactoryGirl.create(:some_question)
      @survey2.questions << @question
      @s2_email_question = FactoryGirl.create(:survey_element, survey: @survey2, element: @email_question, position: 4)
      @question_se = @survey2.survey_elements.find_by(element: @question)

      ENV['PREDEFINED_SURVEY'] = @survey.id.to_s
    end

    should 'show edit form' do
      stub_s3_with_file('sample_import_1.csv')
      assert_difference 'Import.count' do
        post_create_with_file('sample_import_1.csv')
        assert_response :redirect

        import = Import.last
        import.update_attribute(:preview, nil)
        get :edit, id: import.id
        assert_response :success
      end
    end

    should 'successfully create an import and upload contact' do
      stub_s3_with_file('sample_import_1.csv')
      assert_difference 'Person.count' do
        post_create_with_file('sample_import_1.csv')
        assert_response :redirect
        post :update, import: { header_mappings: { '0' => @first_name_element.id, '1' => @last_name_element.id, '2' => @s2_email_question.id } }, id: Import.first.id
        assert_response :redirect
        post :import, use_labels: '0', id: Import.first.id
        Import.last.do_import([])
      end
    end

    should 'should send emails after importing contacts' do
      stub_s3_with_file('sample_import_1.csv')
      assert_difference 'Person.count' do
        post_create_with_file('sample_import_1.csv')
        assert_response :redirect
        post :update, import: { header_mappings: { '0' => @first_name_element.id, '1' => @last_name_element.id, '2' => @s2_email_question.id } }, id: Import.first.id
        assert_response :redirect
        post :import, use_labels: '0', id: Import.first.id

        # Send email to the uploader
        assert_difference('ActionMailer::Base.deliveries.size', 1) do
          Import.last.do_import([])
        end
      end
    end

    should 'should send emails after importing leaders' do
      stub_s3_with_file('sample_import_1.csv')
      assert_difference 'Person.count' do
        post_create_with_file('sample_import_1.csv')
        assert_response :redirect
        post :update, import: { header_mappings: { '0' => @first_name_element.id, '1' => @last_name_element.id, '2' => @email_element.id } }, id: Import.first.id
        assert_response :redirect
        post :import, use_labels: '0', id: Import.first.id

        # Send email to imported leader and to the uploader
        assert_difference('ActionMailer::Base.deliveries.size', 1) do
          Import.last.do_import([Label::LEADER_ID])
        end
      end
    end

    should 'create new survey and question for unmatched header' do
      stub_s3_with_file('sample_import_1.csv')
      post_create_with_file('sample_import_1.csv')
      assert_response :redirect
      post :update, import: { header_mappings: { '0' => @first_name_element.id, '1' => @last_name_element.id, '2' => '' } }, id: Import.first.id
      assert_equal "Import-#{assigns(:import).created_at.strftime('%Y-%m-%d')}", Survey.last.title
      assert_equal assigns(:import).headers[2], Element.last.label
    end

    should 'not create an import if file is empty' do
      stub_s3_with_file('sample_import_blank.csv')
      import_count = Import.count
      post_create_with_file('sample_import_blank.csv')
      assert_response :success
      assert_equal Import.count, import_count
    end

    should 'not create an import if headers (row 1) are not present' do
      stub_s3_with_file('sample_import_2.csv')
      import_count = Import.count
      post_create_with_file('sample_import_2.csv')
      assert_response :success
      assert_equal Import.count, import_count
    end

    should 'not create an import if one of the headers is blank' do
      stub_s3_with_file('sample_import_3.csv')
      import_count = Import.count
      post_create_with_file('sample_import_3.csv')
      assert_response :success
      assert_equal Import.count, import_count
    end

    should 'update the header_mappings and redirect' do
      stub_s3_with_file('sample_import_1.csv')
      post_create_with_file('sample_import_1.csv')
      assert_response :redirect
      post :update, import: { header_mappings: { '0' => @first_name_element.id, '1' => @last_name_element.id, '2' => @email_element.id } }, id: Import.first.id
      Import.last.do_import([])
      assert_equal Import.first.header_mappings['0'].to_i, @first_name_element.id
      assert_equal Import.first.header_mappings['1'].to_i, @last_name_element.id
      assert_equal Import.first.header_mappings['2'].to_i, @email_element.id
      assert_response :redirect
    end

    should 'upload & import contacts if use_labels is false' do
      stub_s3_with_file('sample_import_1.csv')
      post_create_with_file('sample_import_1.csv')
      assert_response :redirect

      post :update, import: { header_mappings: { '0' => @first_name_element.id, '1' => @last_name_element.id, '2' => @email_element.id } }, id: Import.first.id
      assert_equal Import.first.header_mappings['0'].to_i, @first_name_element.id
      assert_equal Import.first.header_mappings['1'].to_i, @last_name_element.id
      assert_equal Import.first.header_mappings['2'].to_i, @email_element.id
      person_count = Person.count

      assert_response :redirect
      # "use_labels"=>"1", "labels"=>["0", "5", "145"], "new_label_field"=>"", "commit"=>"Import Now", "id"=>"13"
      post :import, use_labels: '0', id: Import.first.id
      Import.first.do_import([])
      assert_equal Person.count, person_count + 1
    end

    should 'upload & use existing label & import contacts if use_labels is true' do
      stub_s3_with_file('sample_import_1.csv')
      post_create_with_file('sample_import_1.csv')
      assert_response :redirect

      post :update, import: { header_mappings: { '0' => @first_name_element.id, '1' => @last_name_element.id, '2' => @email_element.id } }, id: Import.first.id
      assert_equal Import.first.header_mappings['0'].to_i, @first_name_element.id
      assert_equal Import.first.header_mappings['1'].to_i, @last_name_element.id
      assert_equal Import.first.header_mappings['2'].to_i, @email_element.id
      person_count = Person.count
      assert_response :redirect
      post :import, use_labels: '1', id: Import.first.id, labels: [@default_label.id]
      Import.last.do_import([@default_label.id])
      assert_equal Person.count, person_count + 1
      new_person = Person.last
      assert new_person.organizational_labels.exists?(label_id: @default_label.id), 'imported person should have specified label'
      assert_response :redirect
    end

    should 'upload & create default label & import contacts if use_labels is true' do
      stub_s3_with_file('sample_import_1.csv')
      post_create_with_file('sample_import_1.csv')
      assert_response :redirect

      post :update, import: { header_mappings: { '0' => @first_name_element.id, '1' => @last_name_element.id, '2' => @email_element.id } }, id: Import.first.id
      assert_equal Import.first.header_mappings['0'].to_i, @first_name_element.id
      assert_equal Import.first.header_mappings['1'].to_i, @last_name_element.id
      assert_equal Import.first.header_mappings['2'].to_i, @email_element.id
      person_count = Person.count
      assert_response :redirect

      post :import, use_labels: '1', id: Import.first.id, labels: [0]
      Import.first.do_import([0])
      assert_equal Person.count, person_count + 1
      new_person = Person.last
      new_label = Label.find_by_name(Import.first.label_name)
      assert new_person.organizational_labels.exists?(label_id: new_label.id), 'imported person should have the default label'
      assert_response :redirect
    end

    should 'succesfully create an import and not upload contact because first_name heading is not specified by the user' do
      stub_s3_with_file('sample_import_1.csv')
      person_count = Person.count
      post_create_with_file('sample_import_1.csv')
      assert_response :redirect

      post :update, import: { header_mappings: { '0' => @last_name_element.id, '1' => @email_element.id } }, id: Import.first.id
      Import.last.do_import([])
      assert_equal Person.count, person_count, 'contact still uploaded despite there is no first_name header, which is required, specified by the user'
    end

    should 'successfully create an import but not upload a contact if one of the emails is invalid' do
      stub_s3_with_file('sample_import_4.csv')
      person_count = Person.count
      post_create_with_file('sample_import_4.csv')
      assert_response :redirect

      post :update, import: {
        header_mappings: {
          '0' => @first_name_element.id, '1' => @last_name_element.id,
          '2' => @phone_element.id, '3' => @email_element.id }
      },
                    id: Import.first.id
      Import.first.do_import([])
      assert_equal Person.count, person_count
    end

    should 'successfully create an import but not upload a contact if one of the phone numbers is invalid' do
      stub_s3_with_file('sample_import_5.csv')
      person_count = Person.count
      post_create_with_file('sample_import_5.csv')
      assert_response :redirect

      post :update, import: {
        header_mappings: {
          '0' => @first_name_element.id, '1' => @last_name_element.id,
          '2' => @phone_element.id, '3' => @email_element.id }
      },
                    id: Import.first.id
      Import.last.do_import([])
      assert_equal Person.count, person_count
    end

    should 'successfully create an import but not upload a contact if at least two of the headers has the same selected person attribute/survey question' do
      stub_s3_with_file('sample_import_5.csv')
      person_count = Person.count
      post_create_with_file('sample_import_5.csv')
      assert_response :redirect

      post :update, import: {
        header_mappings: {
          '0' => @first_name_element.id, '1' => @last_name_element.id,
          '2' => @phone_element.id, '3' => @email_element.id }
      },
                    id: Import.first.id
      Import.last.do_import([])
      assert_equal Person.count, person_count
    end

    should 'not create an import if file is invalid' do
      stub_s3_with_file('sample_import_6.ods')
      assert_raise 'RuntimeError' do
        post_create_with_file('sample_import_6.ods')
      end
    end

    should 'edit import file' do
      stub_s3_with_file('sample_import_1.csv')

      predefined_survey = FactoryGirl.create(:survey)
      ENV['PREDEFINED_SURVEY'] = predefined_survey.id.to_s
      post_create_with_file('sample_import_1.csv')
      post :edit, id: Import.last.id
      assert_template 'imports/edit'
    end

    #     should "successfully destroy an import" do
    #       stub_s3_with_file('sample_import_1.csv')
    #
    #       post_create_with_file('sample_import_1.csv')
    #
    #       stub_request(:delete, S3_URL_REGEXP).to_return(body: File.new(Rails.root.join("test/fixtures/contacts_upload_csv/sample_import_1.csv")), status: 200)
    #       post :destroy, {:id => Import.last.id}
    #       assert_response :redirect
    #     end

    should 'successfully create an import and upload contact with non-predefined surveys' do
      stub_s3_with_file('sample_import_7.csv')

      post_create_with_file('sample_import_7.csv')
      assert_response :redirect

      assert_difference 'AnswerSheet.count', 2 do
        post :update, import: {
          header_mappings: {
            '0' => @first_name_element.id, '1' => @last_name_element.id,
            '3' => @s2_email_question.id, '4' => @question_se.id }
        },
                      id: Import.last.id
        post :import, use_labels: '0', id: Import.last.id
        Import.last.do_import
      end
      person = Person.last
      answer_sheet = person.answer_sheets.find_by(survey_id: @survey2.id)
      assert_equal answer_sheet.answers.first.value, 'I just met you'
    end

    should 'successfully create an import and redirect to labels' do
      stub_s3_with_file('sample_import_7.csv')

      post_create_with_file('sample_import_7.csv')
      assert_response :redirect

      post :update, import: {
        header_mappings: {
          '0' => @first_name_element.id, '1' => @last_name_element.id,
          '3' => @email_element.id, '4' => @question_se.id }
      },
                    id: Import.first.id
      assert_redirected_to "/imports/#{Import.last.id}/labels"
      get :labels, id: Import.last.id
    end

    should 'successfully creates answer sheets only for imported surveys' do
      survey3 = FactoryGirl.create(:survey, organization: @organization)
      FactoryGirl.create(:survey_element, survey: survey3, element: @email_question)
      FactoryGirl.create(:survey_element, survey: survey3, element: FactoryGirl.create(:some_question))

      stub_s3_with_file('sample_import_7.csv')
      post_create_with_file('sample_import_7.csv')
      assert_response :redirect
      assert_difference 'AnswerSheet.count', 2 do
        post :update, import: {
          header_mappings: {
            '0' => @first_name_element.id, '1' => @last_name_element.id,
            '3' => @s2_email_question.id, '4' => @question_se.id }
        },
                      id: Import.last.id
        post :import, use_labels: '0', id: Import.last.id
        Import.last.do_import
      end
    end

    context 'get_survey_questions' do
      setup do
        stub_s3_with_file('sample_import_7.csv')
        post_create_with_file('sample_import_7.csv')
        @controller.send(:get_survey_questions)
        @survey_questions = assigns(:survey_questions)
      end

      should 'include predefined questions' do
        assert_includes @survey_questions[I18n.t('surveys.questions.index.predefined')].to_h.values,
                        SurveyElement.joins(:element)
          .find_by(survey_id: ENV['PREDEFINED_SURVEY'], elements: { attribute_name: 'first_name' })
          .id
      end

      should 'include survey questions' do
        assert_includes @survey_questions[@survey2.title].to_h.values, @question_se.id
      end
    end
  end
end
