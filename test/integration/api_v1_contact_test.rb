require 'test_helper'
include ApiTestHelper

class ApiV1ContactTest < ActionDispatch::IntegrationTest
  context "the api" do
    setup do
      setup_api_env()
    end
    
    # should "be able to view a specific contact" do
    #   path = "/api/contacts/#{@user.person.id}"
    #   get path, {'access_token' => @access_token3.code}
    #   assert_response :success, @response.body
    #   @json = ActiveSupport::JSON.decode(@response.body)
    # 
    #   keyword_test(@json['keywords'], @keyword)
    #   question_test(@json['questions'], @questions)
    #   person_basic_test(@json['people'][0]['person'], @user, @user2)
    #   form_test(@json['people'][0]['form'], @questions, @answer_sheet)
    # end
  
    should "be able to view a specific contact with a specific version" do
      path = "/api/v1/contacts/#{@user.person.id}"
      get path, {'access_token' => @access_token3.code}
      assert_response :success, @response.body
      @json = ActiveSupport::JSON.decode(@response.body)
      
      keyword_test(@json['keywords'], @keyword)
      question_test(@json['questions'], @questions)
      person_basic_test(@json['people'][0]['person'], @user, @user2)
      form_test(@json['people'][0]['form'], @questions, @answer_sheet)
    end
  end
end