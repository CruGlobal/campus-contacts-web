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
    get :new
    #assert_response :success
  end

  test "should get create" do
    get :create
    #assert_response :success
  end

  test "should get edit" do
    get :edit
    #assert_response :success
  end

  test "should get update" do
    get :update
    #assert_response :success
  end

  test "should get destroy" do
    get :destroy
    #assert_response :success
  end



  context "Importing contacts" do
    setup do
      @user = Factory(:user_with_auxs)  #user with a person object
      sign_in @user

      @organization = Factory(:organization)
      @survey = Factory(:survey, organization: @organization, id: 2)
      @firstName_element = Factory(:firstName_element)
      @lastName_element = Factory(:lastName_element)
      @email_element = Factory(:email_element)
      @firstName_question = Factory(:survey_element, survey: @survey, element: @firstName_element, position: 1, archived: true)
      @lastName_question = Factory(:survey_element, survey: @survey, element: @lastName_element, position: 2, archived: true)
      @email_question = Factory(:survey_element, survey: @survey, element: @email_element, position: 3, archived: true)
    end
    
    should "successfully create an import and upload contact" do
      person_count  = Person.count
      contacts_file = File.open(Rails.root.join("test/fixtures/contacts_upload_csv/sample_import_1.csv"))
      file = Rack::Test::UploadedFile.new(contacts_file, "application/csv")
      post :create, { :import => { :upload => file } }
      assert_response 302
      
      #puts Import.all.inspect
      #puts @survey.inspect
      #puts Question.all.inspect
      #puts @survey.elements.inspect      
      
      post :update, { :import => { :header_mappings => {"0" => @firstName_element.id, "1" => @lastName_element.id, "2" => @email_element.id} }, :id => Import.first.id}
      assert_equal Person.count, person_count + 1, "Upload of contacts csv file unsuccessful"
      puts Person.count
      puts person_count
    end 
  end
end
