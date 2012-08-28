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

  context "Importing contacts" do
    setup do
      stub_request(:put, /https:\/\/s3\.amazonaws\.com\/.*\/mh\/imports\/uploads\/.*/)

      @user, @organization = admin_user_login_with_org

      @survey = Factory(:survey, organization: @organization, id: 2)
      @firstName_element = Factory(:firstName_element)
      @lastName_element = Factory(:lastName_element)
      @email_element = Factory(:email_element)
      @phone_element = Factory(:phone_element)
      @firstName_question = Factory(:survey_element, survey: @survey, element: @firstName_element, position: 1, archived: true)
      @lastName_question = Factory(:survey_element, survey: @survey, element: @lastName_element, position: 2, archived: true)
      @email_question = Factory(:survey_element, survey: @survey, element: @email_element, position: 3, archived: true)
      @phone_question = Factory(:survey_element, survey: @survey, element: @phone_element, position: 4, archived: true)
      
      
      @survey2 = Factory(:survey, organization: @organization)
      @question = Factory(:some_question)
      @survey2.questions << @question
      
      APP_CONFIG['predefined_survey'] = 2
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
    
    should "successfully create an import and upload contact" do
      stub_request(:get, /https:\/\/s3\.amazonaws\.com\/.*\/mh\/imports\/uploads\/.*/).
        to_return(body: File.new(Rails.root.join("test/fixtures/contacts_upload_csv/sample_import_1.csv")), status: 200)
      assert_difference "Person.count" do
        contacts_file = File.open(Rails.root.join("test/fixtures/contacts_upload_csv/sample_import_1.csv"))
        file = Rack::Test::UploadedFile.new(contacts_file, "application/csv")
        post :create, { :import => { :upload => file } }
        assert_response :redirect
        
        post :update, { :import => { :header_mappings => {"0" => @firstName_element.id, "1" => @lastName_element.id, "2" => @email_element.id} }, :id => Import.first.id}
      end
    end
    
    should "succesfully create an import and unsuccesfully upload contact because firstName heading is not specified by the user" do 
      stub_request(:get, /https:\/\/s3\.amazonaws\.com\/.*\/mh\/imports\/uploads\/.*/).
        to_return(body: File.new(Rails.root.join("test/fixtures/contacts_upload_csv/sample_import_1.csv")), status: 200)
      person_count  = Person.count
      contacts_file = File.open(Rails.root.join("test/fixtures/contacts_upload_csv/sample_import_1.csv"))
      file = Rack::Test::UploadedFile.new(contacts_file, "application/csv")
      post :create, { :import => { :upload => file } }
      assert_response :redirect    
      
      post :update, { :import => { :header_mappings => {"0" => @lastName_element.id, "1" => @email_element.id} }, :id => Import.first.id}
      assert_equal Person.count, person_count, "contact still uploaded despite there is no firstName header, which is required, specified by the user"
    end
    
    should "successfully create an import but unsuccesfully upload a contact if one of the emails is invalid" do
      stub_request(:get, /https:\/\/s3\.amazonaws\.com\/.*\/mh\/imports\/uploads\/.*/).
        to_return(body: File.new(Rails.root.join("test/fixtures/contacts_upload_csv/sample_import_4.csv")), status: 200)
      person_count  = Person.count
      contacts_file = File.open(Rails.root.join("test/fixtures/contacts_upload_csv/sample_import_4.csv"))
      file = Rack::Test::UploadedFile.new(contacts_file, "application/csv")
      post :create, { :import => { :upload => file } }
      assert_response :redirect
      
      post :update, { :import => { :header_mappings => {"0" => @firstName_element.id, "1" => @lastName_element.id, "2" => @phone_element.id, "3" => @email_element.id} }, :id => Import.first.id}
      assert_equal Person.count, person_count
    end
    
    should "successfully create an import but unsuccesfully upload a contact if one of the phone numbersd is invalid" do
      stub_request(:get, /https:\/\/s3\.amazonaws\.com\/.*\/mh\/imports\/uploads\/.*/).
        to_return(body: File.new(Rails.root.join("test/fixtures/contacts_upload_csv/sample_import_5.csv")), status: 200)
      person_count  = Person.count
      contacts_file = File.open(Rails.root.join("test/fixtures/contacts_upload_csv/sample_import_5.csv"))
      file = Rack::Test::UploadedFile.new(contacts_file, "application/csv")
      post :create, { :import => { :upload => file } }
      assert_response :redirect
      
      post :update, { :import => { :header_mappings => {"0" => @firstName_element.id, "1" => @lastName_element.id, "2" => @phone_element.id, "3" => @email_element.id} }, :id => Import.first.id}
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
      
      post :update, { :import => { :header_mappings => {"0" => @firstName_element.id, "1" => @firstName_element.id, "2" => @phone_element.id, "3" => @email_element.id} }, :id => Import.first.id}
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
          post :update, { :import => { :header_mappings => {"0" => @firstName_element.id, "1" => @lastName_element.id, "3" => @email_element.id, "4" => @question.id} }, :id => Import.first.id}
          assert_equal Person.last.answer_sheets.first.answers.first.value, "I just met you"
        end
    end
  end
end
