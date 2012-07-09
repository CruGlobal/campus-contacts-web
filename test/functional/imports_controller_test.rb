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

=begin  

  context "Importing contacts" do
    setup do
      @user = Factory(:user_with_auxs)  #user with a person object
      sign_in @user

      organization = Factory(:organization)
      survey = Factory(:survey, organization: organization)
      element = Factory(:choice_field)
      question = Factory(:survey_element, survey: survey, element: element, position: 1, archived: true)

    end
    
    should "successfully import contacts" do
      contacts_file = File.open(Rails.root.join("test/fixtures/contacts_upload_csv/sample_contacts.csv"))
      file = Rack::Test::UploadedFile.new(contacts_file, "application/csv")
      person_count  = Person.count
      post :csv_import, { :dump => { :file => file } }
      assert_equal Person.count, person_count + 1, "Upload of contacts csv file unsuccessful"
      assert_response :success, "Upload of contacts csv file unsuccessful"
    end

    should "unsuccessfully import contacts when a row is missing First Name" do
      #"sample_contacts_missing_firstname"
      contacts_file = File.open(Rails.root.join("test/fixtures/contacts_upload_csv/sample_contacts_missing_firstname.csv"))
      file = Rack::Test::UploadedFile.new(contacts_file, "application/csv")
      person_count  = Person.count
      post :csv_import, { :dump => { :file => file } }
      assert_equal "CSV Import unsuccessful for some rows:<br/> First name is blank at row/s 2,  <br/> Invalid email address at row/s 1,  <br/>", flash[:error]
      assert_equal Person.count, person_count, "Upload of contacts csv file successful (should not be successful)."
      assert_response :success, "Upload of contacts csv file unsuccessful"
    end

    should "unsuccessfully import contacts when a row has wrong phone number format" do
      #"sample_contacts_missing_firstname"
      contacts_file = File.open(Rails.root.join("test/fixtures/contacts_upload_csv/sample_contacts_missing_firstname.csv"))
      file = Rack::Test::UploadedFile.new(contacts_file, "application/csv")
      person_count  = Person.count
      post :csv_import, { :dump => { :file => file } }

      assert_equal "CSV Import unsuccessful for some rows:<br/> First name is blank at row/s 2,  <br/> Invalid email address at row/s 1,  <br/>", flash[:error]
      assert_equal Person.count, person_count, "Upload of contacts csv file successful (should not be successful)."
      assert_response :success, "Upload of contacts csv file unsuccessful"
    end

    should "unsuccessfully import contacts when a row has wrong email format" do
      #"sample_contacts_missing_firstname"
      contacts_file = File.open(Rails.root.join("test/fixtures/contacts_upload_csv/sample_contacts_missing_firstname.csv"))
      file = Rack::Test::UploadedFile.new(contacts_file, "application/csv")
      person_count  = Person.count
      post :csv_import, { :dump => { :file => file } }

      assert_equal "CSV Import unsuccessful for some rows:<br/> First name is blank at row/s 2,  <br/> Invalid email address at row/s 1,  <br/>", flash[:error]
      assert_equal Person.count, person_count, "Upload of contacts csv file successful (should not be successful)."
      assert_response :success, "Upload of contacts csv file unsuccessful"
    end
  end

  test "import contacts" do
    user, org = admin_user_login_with_org
    get :import_contacts
    assert_not_nil assigns(:organization)
  end
  
=end

end
