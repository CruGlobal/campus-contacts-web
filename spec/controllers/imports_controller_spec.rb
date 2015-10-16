require 'rails_helper'

RSpec.describe ImportsController, type: :controller do
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

  before do
    @user, @organization = admin_user_login_with_org
  end

  it 'should get new' do
    get :new
    expect(response).to be_success
  end

  it 'should download sample contacts csv' do
    get :download_sample_contacts_csv
    expect(response).to be_success
  end

  context 'Adding survey questions' do
    before do
      @survey = FactoryGirl.create(:survey, organization: @organization)
    end

    it 'add question for an existing survey' do
      xhr :get, :create_survey_question, select_survey_field: @survey.id,
                                         question_category: 'TextField:short', question: 'This is a sample question',
                                         question_id: '', id: 1
      expect(assigns(:question)).to eq Element.last
      expect(SurveyElement.last.survey).to eq @survey
      expect(SurveyElement.last.question.label).to eq 'This is a sample question'
    end

    it 'create a new survey' do
      xhr :get, :create_survey_question,
          create_survey_toggle: 'new_survey', survey_name_field: 'New Survey for Testing',
          question_category: 'ChoiceField:radio', question: 'What is your gender?',
          options: 'Male\r\nFemale', question_id: '', id: 1
      expect(SurveyElement.last.question.label).to eq 'What is your gender?'
      expect(SurveyElement.last.survey.title).to eq 'New Survey for Testing'
    end
  end

  context 'Updating survey questions' do
    before do
      @survey = FactoryGirl.create(:survey, organization: @organization)
      @question = FactoryGirl.create(:choice_field, label: 'This is the original question', content: 'Male\r\nFemale')
      FactoryGirl.create(:survey_element, survey: @survey, element: @question)
    end

    it 'change the question' do
      expect(Element.find(@question.id).content).to eq 'Male\r\nFemale'
      expect(Element.find(@question.id).label).to eq 'This is the original question'

      xhr :get, :create_survey_question, question: 'This is the revised question',
                                         options: 'Male\r\nFemale\r\nOther', question_id: @question.id, id: '1'

      expect(Element.find(@question.id).label).to eq 'This is the revised question'
      expect(Element.find(@question.id).content).to eq 'Male\r\nFemale\r\nOther'
    end
  end

  describe 'Importing contacts' do
    shared_examples 'failed import' do |file|
      it "doesn't change Import count" do
        expect do
          stub_s3_with_file file
          post_create_with_file file
          expect(response).to be_success
        end.to_not change { Import.count }
      end
    end

    before do
      stub_request(:put, S3_URL_REGEXP)

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

    it 'show edit form' do
      stub_s3_with_file('sample_import_1.csv')
      expect do
        post_create_with_file('sample_import_1.csv')
        assert_response :redirect

        import = Import.last
        import.update_attribute(:preview, nil)
        get :edit, id: import.id
        expect(response).to be_success
      end.to change { Import.count }
    end

    it 'successfully create an import and upload contact' do
      stub_s3_with_file('sample_import_1.csv')
      expect do
        post_create_with_file('sample_import_1.csv')
        assert_response :redirect
        post :update, import: {
          header_mappings: {
            '0' => @first_name_element.id, '1' => @last_name_element.id, '2' => @s2_email_question.id
          }
        }, id: Import.first.id
        assert_response :redirect
        post :import, use_labels: '0', id: Import.first.id
        Import.last.do_import([])
      end.to change { Person.count }
    end

    it 'should send emails after importing contacts' do
      stub_s3_with_file('sample_import_1.csv')
      expect do
        post_create_with_file('sample_import_1.csv')
        assert_response :redirect
        post :update, import: {
          header_mappings: {
            '0' => @first_name_element.id, '1' => @last_name_element.id, '2' => @s2_email_question.id
          }
        }, id: Import.first.id
        assert_response :redirect
        post :import, use_labels: '0', id: Import.first.id

        # Send email to the uploader
        Import.last.do_import([])
      end.to change { Person.count }.and change { ActionMailer::Base.deliveries.size }.by(1)
    end

    it 'should send emails after importing leaders' do
      stub_s3_with_file('sample_import_1.csv')
      expect do
        post_create_with_file('sample_import_1.csv')
        assert_response :redirect
        post :update, import: {
          header_mappings: {
            '0' => @first_name_element.id, '1' => @last_name_element.id, '2' => @email_element.id
          }
        }, id: Import.first.id
        assert_response :redirect
        post :import, use_labels: '0', id: Import.first.id

        # Send email to imported leader and to the uploader
        Import.last.do_import([Label::LEADER_ID])
      end.to change { Person.count }.and change { ActionMailer::Base.deliveries.size }.by(1)
    end

    it 'create new survey and question for unmatched header' do
      stub_s3_with_file('sample_import_1.csv')
      post_create_with_file('sample_import_1.csv')
      assert_response :redirect
      post :update, import: {
        header_mappings: {
          '0' => @first_name_element.id, '1' => @last_name_element.id, '2' => ''
        }
      }, id: Import.first.id
      expect(Survey.last.title).to eq "Import-#{assigns(:import).created_at.strftime('%Y-%m-%d')}"
      expect(assigns(:import).headers[2]).to eq Element.last.label
    end

    describe 'with empty file' do
      it_behaves_like 'failed import', 'sample_import_blank.csv'
    end

    describe 'not create an import if headers (row 1) are not present' do
      it_behaves_like 'failed import', 'sample_import_2.csv'
    end

    describe 'not create an import if one of the headers is blank' do
      it_behaves_like 'failed import', 'sample_import_3.csv'
    end

    it 'creates an import if trailing blank headers' do
      expect do
        stub_s3_with_file('sample_import_10.csv')
        post_create_with_file('sample_import_10.csv')
        assert_response :redirect
        post :update, import: {
          header_mappings: {
            '0' => @first_name_element.id, '1' => @last_name_element.id,
            '2' => @phone_element.id, '3' => @email_element.id }
        },
                      id: Import.first.id
        Import.last.do_import([])
      end.to change { Import.count }.by(1).and change { Person.count }.by(1)
    end

    def post_update_with_predefined_headers
      stub_s3_with_file('sample_import_1.csv')
      post_create_with_file('sample_import_1.csv')
      assert_response :redirect
      post :update, import: {
        header_mappings: {
          '0' => @first_name_element.id, '1' => @last_name_element.id, '2' => @email_element.id
        }
      }, id: Import.first.id
    end

    it 'update the header_mappings and redirect' do
      post_update_with_predefined_headers
      Import.last.do_import([])
      expect(Import.first.header_mappings['0'].to_i).to eq @first_name_element.id
      expect(Import.first.header_mappings['1'].to_i).to eq @last_name_element.id
      expect(Import.first.header_mappings['2'].to_i).to eq @email_element.id
      assert_response :redirect
    end

    it 'upload & import contacts if use_labels is false' do
      post_update_with_predefined_headers
      assert_response :redirect
      expect do
        post :import, use_labels: '0', id: Import.first.id
        Import.first.do_import([])
      end.to change { Person.count }.by 1
    end

    it 'upload & use existing label & import contacts if use_labels is true' do
      post_update_with_predefined_headers
      expect do
        assert_response :redirect
        post :import, use_labels: '1', id: Import.first.id, labels: [@default_label.id]
        Import.last.do_import([@default_label.id])
      end.to change { Person.count }.by 1
      expect(Person.last.labels).to include(@default_label),
                                    'imported person should have specified label'
      assert_response :redirect
    end

    it 'upload & create default label & import contacts if use_labels is true' do
      post_update_with_predefined_headers
      expect do
        assert_response :redirect
        post :import, use_labels: '1', id: Import.first.id, labels: [0]
        Import.first.do_import([0])
      end.to change { Person.count }.by 1
      new_label = Label.find_by(name: Import.first.label_name)
      expect(Person.last.labels).to include(new_label),
                                    'imported person should have the default label'
      assert_response :redirect
    end

    it 'succesfully create an import and not upload contact because '\
           'first_name heading is not specified by the user' do
      stub_s3_with_file('sample_import_1.csv')
      expect do
        post_create_with_file('sample_import_1.csv')
        assert_response :redirect

        post :update, import: { header_mappings: { '0' => @last_name_element.id, '1' => @email_element.id } },
                      id: Import.first.id
        Import.last.do_import([])
      end.to_not change { Person.count },
                 'contact still uploaded despite there is no first_name '\
                     'header, which is required, specified by the user'
    end

    it 'successfully create an import but not upload a contact if one of the emails is invalid' do
      expect do
        stub_s3_with_file('sample_import_4.csv')
        post_create_with_file('sample_import_4.csv')
        assert_response :redirect

        post :update, import: {
          header_mappings: {
            '0' => @first_name_element.id, '1' => @last_name_element.id,
            '2' => @phone_element.id, '3' => @email_element.id }
        },
                      id: Import.first.id
        Import.first.do_import([])
      end.to_not change { Person.count }
    end

    it 'successfully create an import but not upload a contact if one of the phone numbers is invalid' do
      expect do
        stub_s3_with_file('sample_import_5.csv')
        post_create_with_file('sample_import_5.csv')
        assert_response :redirect

        post :update, import: {
          header_mappings: {
            '0' => @first_name_element.id, '1' => @last_name_element.id,
            '2' => @phone_element.id, '3' => @email_element.id }
        },
                      id: Import.first.id
        Import.last.do_import([])
      end.to_not change { Person.count }
    end

    it 'successfully create an import but not upload a contact if at least two of the headers has '\
           'the same selected person attribute/survey question' do
      stub_s3_with_file('sample_import_5.csv')

      expect do
        post_create_with_file('sample_import_5.csv')
        assert_response :redirect

        post :update, import: {
          header_mappings: {
            '0' => @first_name_element.id, '1' => @last_name_element.id,
            '2' => @phone_element.id, '3' => @email_element.id }
        },
                      id: Import.first.id
        Import.last.do_import([])
      end.to_not change { Person.count }
    end

    describe 'with invalid file' do
      it_behaves_like 'failed import', 'sample_import_6.ods'
    end

    it 'edit import file' do
      stub_s3_with_file('sample_import_1.csv')

      predefined_survey = FactoryGirl.create(:survey)
      ENV['PREDEFINED_SURVEY'] = predefined_survey.id.to_s
      post_create_with_file('sample_import_1.csv')
      post :edit, id: Import.last.id
      assert_template 'imports/edit'
    end

    it 'successfully create an import and upload contact with non-predefined surveys' do
      stub_s3_with_file('sample_import_7.csv')

      post_create_with_file('sample_import_7.csv')
      assert_response :redirect

      expect do
        post :update, import: {
          header_mappings: {
            '0' => @first_name_element.id, '1' => @last_name_element.id,
            '3' => @s2_email_question.id, '4' => @question_se.id }
        },
                      id: Import.last.id
        post :import, use_labels: '0', id: Import.last.id
        Import.last.do_import
      end.to change { AnswerSheet.count }.by 2
      person = Person.last
      answer_sheet = person.answer_sheets.find_by(survey_id: @survey2.id)
      expect(answer_sheet.answers.first.value).to eq 'I just met you'
    end

    it 'successfully create an import and redirect to labels' do
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

    it 'successfully creates answer sheets only for imported surveys' do
      survey3 = FactoryGirl.create(:survey, organization: @organization)
      FactoryGirl.create(:survey_element, survey: survey3, element: @email_question)
      FactoryGirl.create(:survey_element, survey: survey3, element: FactoryGirl.create(:some_question))

      stub_s3_with_file('sample_import_7.csv')
      post_create_with_file('sample_import_7.csv')
      assert_response :redirect
      expect do
        post :update, import: {
          header_mappings: {
            '0' => @first_name_element.id, '1' => @last_name_element.id,
            '3' => @s2_email_question.id, '4' => @question_se.id }
        },
                      id: Import.last.id
        post :import, use_labels: '0', id: Import.last.id
        Import.last.do_import
      end.to change { AnswerSheet.count }.by 2
    end

    context '#get_survey_questions' do
      before do
        stub_s3_with_file('sample_import_7.csv')
        post_create_with_file('sample_import_7.csv')
        @controller.send(:get_survey_questions)
        @survey_questions = assigns(:survey_questions)
      end

      it 'include predefined questions' do
        se_id = SurveyElement.joins(:element)
                .find_by(survey_id: ENV['PREDEFINED_SURVEY'], elements: { attribute_name: 'first_name' }).id
        expect(@survey_questions[I18n.t('surveys.questions.index.predefined')].to_h.values).to include se_id
      end

      it 'include survey questions' do
        expect(@survey_questions[@survey2.title].to_h.values).to include @question_se.id
      end
    end
  end
end
