require 'test_helper'

class Apis::V3::PeopleControllerTest < ActionController::TestCase
  setup do
    request.env["HTTP_ACCEPT"] = "application/json"
    @org = FactoryGirl.create(:organization)
    @client = FactoryGirl.create(:client, organization: @org)

    # Admin
    @user1 = FactoryGirl.create(:user_api)
    @person1 = @user1.person
    @org.add_admin(@person1)
    @admin_permission = @person1.permission_for_org_id(@org.id)
    @admin_token = FactoryGirl.create(:access_token, identity: @user1.id, client_id: @client.id)

    # User
    @user2 = FactoryGirl.create(:user_api)
    @person2 = @user2.person
    @org.add_user(@person2)
    @user_permission = @person2.permission_for_org_id(@org.id)
    @user_token = FactoryGirl.create(:access_token, identity: @user2.id, client_id: @client.id)

    # No Permission
    @user3 = FactoryGirl.create(:user_api)
    @person3 = @user3.person
    @org.add_contact(@person3)
    @contact_permission = @person3.permission_for_org_id(@org.id)
    @no_permission_token = FactoryGirl.create(:access_token, identity: @user3.id, client_id: @client.id)

    # Other
    @label1 = FactoryGirl.create(:label, organization: @org)
    @label2 = FactoryGirl.create(:label, organization: @org)

    @person = FactoryGirl.create(:person)
    FactoryGirl.create(:email_address, person: @person)
    @org.add_contact(@person)
    @org_permission = @org.organizational_permissions.last

    @another_person = FactoryGirl.create(:person)
    FactoryGirl.create(:email_address, person: @another_person)
    @org.add_contact(@another_person)
    @another_org_permission = @org.organizational_permissions.last

    @no_org_person = FactoryGirl.create(:person)
    FactoryGirl.create(:email_address, person: @no_org_person)

    @another_no_org_person = FactoryGirl.create(:person)
    FactoryGirl.create(:email_address, person: @another_no_org_person)
  end

  context ".index" do
    context "ADMIN request" do
      setup do
        @token = @admin_token.code
      end
      should "return a list of people" do
        get :index, access_token: @token
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal @org.people.count, json['people'].count, json.inspect
      end
    end
    context "USER request" do
      setup do
        @token = @user_token.code
      end
      should "return a list of people" do
        get :index, access_token: @token
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal @org.people.count, json['people'].count, json.inspect
      end
    end
    context "NO_PERMISSION request" do
      setup do
        @token = @no_permission_token.code
      end
      should "not return a list of people" do
        get :index, access_token: @token
        json = JSON.parse(response.body)
        assert_not_nil json["errors"], json.inspect
      end
    end
  end

  context ".show" do
    context "ADMIN request" do
      setup do
        @token = @admin_token.code
      end
      should "return a person" do
        get :show, access_token: @token, id: @person.id
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal @person.id, json['person']['id'], json.inspect
      end
    end
    context "USER request" do
      setup do
        @token = @user_token.code
      end
      should "return a person" do
        get :show, access_token: @token, id: @person.id
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal @person.id, json['person']['id'], json.inspect
      end
    end
    context "NO_PERMISSION request" do
      setup do
        @token = @no_permission_token.code
      end
      should "not return a person" do
        get :show, access_token: @token, id: @person.id
        json = JSON.parse(response.body)
        assert_not_nil json["errors"], json.inspect
      end
    end
  end

  context ".create" do
    context "ADMIN request" do
      setup do
        @token = @admin_token.code
      end
      should "create and return a person" do
        assert_difference "Person.count" do
          post :create, access_token: @token,
                person: {first_name: "FirstName", last_name: "LastName"}
        end
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal "FirstName", json['person']['first_name'], json.inspect
      end
    end
    context "USER request" do
      setup do
        @token = @user_token.code
      end
      should "create and return a person" do
        assert_difference "Person.count" do
          post :create, access_token: @token,
                person: {first_name: "FirstName", last_name: "LastName"}
        end
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal "FirstName", json['person']['first_name'], json.inspect
      end
    end
    context "NO_PERMISSION request" do
      setup do
        @token = @no_permission_token.code
      end
      should "not create and return a person" do
        assert_difference "Person.count", 0 do
          post :create, access_token: @token,
                person: {first_name: "FirstName", last_name: "LastName"}
        end
        json = JSON.parse(response.body)
        assert_not_nil json["errors"], json.inspect
      end
    end
  end

  context ".update" do
    context "ADMIN request" do
      setup do
        @token = @admin_token.code
      end
      should "update and return a person" do
        post :update, access_token: @token, id: @person.id,
              person: {first_name: "FirstName"}
        assert_response :success
        json = JSON.parse(response.body)
        @person.reload
        assert_equal "FirstName", json['person']['first_name'], json.inspect
        assert_equal "FirstName", @person.first_name
      end
    end
    context "USER request" do
      setup do
        @token = @user_token.code
      end
      should "update and return a person" do
        post :update, access_token: @token, id: @person.id,
              person: {first_name: "FirstName"}
        assert_response :success
        json = JSON.parse(response.body)
        @person.reload
        assert_equal "FirstName", json['person']['first_name'], json.inspect
        assert_equal "FirstName", @person.first_name
      end
    end
    context "NO_PERMISSION request" do
      setup do
        @token = @no_permission_token.code
      end
      should "not update and return a person" do
        post :update, access_token: @token, id: @person,
              person: {first_name: "FirstName"}
        json = JSON.parse(response.body)
        assert_not_nil json["errors"], json.inspect
      end
    end
  end

  context ".destroy" do
    context "ADMIN request" do
      setup do
        @token = @admin_token.code
      end
      should "destroy a person" do
        delete :destroy, access_token: @token, id: @person.id
        assert_response :success
        @org_permission.reload
        assert_not_nil @org_permission.deleted_at
      end
    end
    context "USER request" do
      setup do
        @token = @user_token.code
      end
      should "destroy a person" do
        delete :destroy, access_token: @token, id: @person.id
        assert_response :success
        @org_permission.reload
        assert_not_nil @org_permission.deleted_at
      end
    end
    context "NO_PERMISSION request" do
      setup do
        @token = @no_permission_token.code
      end
      should "not destroy a person" do
        delete :destroy, access_token: @token, id: @person.id
        json = JSON.parse(response.body)
        assert_not_nil json["errors"], json.inspect
        @org_permission.reload
        assert_nil @org_permission.deleted_at
      end
    end
  end

  context '.bulk_destroy' do
    setup do
      @token = @admin_token.code
    end
    should 'destroy people by filter ids' do
      delete :bulk_destroy, filters: {ids: @person.id}, access_token: @token
      assert_nil assigns(:people)
    end
    should 'destroy people by filter permission' do
      delete :bulk_destroy, filters: {permissions: @person.organizational_permissions.first.permission_id}, access_token: @token
      assert_nil assigns(:people)
    end
  end

  context 'filter' do
    setup do
      @token = @admin_token.code

      @extra1 = FactoryGirl.create(:person, first_name: "Anne", last_name: "Smith")
      FactoryGirl.create(:email_address, person: @extra1, email: "chubbybaby@email.com")
      @org.add_contact(@extra1)
    end
    should 'not raise an error when searching for first name' do
      get :index, filters: {name_or_email_like: "Anne"}, access_token: @token
      assert_response :success
      json = JSON.parse(response.body)
      assert_equal 1, json['people'].count, json.inspect
    end
    should 'not raise an error when searching for last name' do
      get :index, filters: {name_or_email_like: "Smith"}, access_token: @token
      assert_response :success
      json = JSON.parse(response.body)
      assert_equal 1, json['people'].count, json.inspect
    end
    should 'not raise an error when searching for email' do
      get :index, filters: {name_or_email_like: "chubbybaby@email.com"}, access_token: @token
    end
    should 'not raise an error when searching for incomplete email' do
      get :index, filters: {name_or_email_like: "chubby"}, access_token: @token
    end

    should 'not raise an error when searching with multiple results' do

      @extra2 = FactoryGirl.create(:person, first_name: "Chubby", last_name: "Rex")
      @org.add_contact(@extra2)

      get :index, filters: {name_or_email_like: "chubby"}, access_token: @token
      assert_response :success
      json = JSON.parse(response.body)
      assert_equal 2, json['people'].count, json.inspect
    end
  end

  context ".index request" do
    setup do
      @token = @admin_token.code
    end
    context "first_name_like filter" do
      setup do
        @person1.update_attributes(first_name: "Lizzy")
        @person2.update_attributes(first_name: "Larry")
        @person3.update_attributes(first_name: "Sunny")
      end
      should "work when 1 contacts meet the condition" do
        get :index, access_token: @token, filters: {first_name_like: "s"}
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal 1, json['people'].count, json.inspect
      end
      should "work when 2 contacts meet the condition" do
        get :index, access_token: @token, filters: {first_name_like: "l"}
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal 2, json['people'].count, json.inspect
      end
    end
  end

  context "survey answer filter" do
    setup do
      @token = @admin_token.code

      @survey = FactoryGirl.create(:survey, organization: @org)
      @question1 = FactoryGirl.create(:text_field, notify_via: "Both", trigger_words: "Short")
      @survey.questions << @question1
      @question2 = FactoryGirl.create(:text_field, notify_via: "Both", trigger_words: "Short")
      @survey.questions << @question2

      @answer_sheet1 = FactoryGirl.create(:answer_sheet, survey: @survey, person: @person1)
      @answer = FactoryGirl.create(:answer, value: "abc", answer_sheet: @answer_sheet1, question: @question1)
      @answer = FactoryGirl.create(:answer, value: "abc", answer_sheet: @answer_sheet1, question: @question2)

      @answer_sheet2 = FactoryGirl.create(:answer_sheet, survey: @survey, person: @person2)
      @answer = FactoryGirl.create(:answer, value: "bcd", answer_sheet: @answer_sheet2, question: @question1)
      @answer = FactoryGirl.create(:answer, value: "bcd", answer_sheet: @answer_sheet2, question: @question2)

    end
    should "return 1 contact that meets the condition" do
      get :index, access_token: @token, filters: {surveys: {@survey.id.to_s => {questions: {@question1.id.to_s => "ab"}}}}
      assert_response :success
      json = JSON.parse(response.body)
      assert_equal 1, json['people'].count, json.inspect
    end
    should "return 2 contacts that meet the condition" do
      get :index, access_token: @token, filters: {surveys: {@survey.id.to_s => {questions: {@question1.id.to_s => "ab"}}}}
      assert_response :success
      json = JSON.parse(response.body)
      assert_equal 1, json['people'].count, json.inspect
    end
    should "not return contacts that didnt meet the condition" do
      get :index, access_token: @token, filters: {surveys: {@survey.id.to_s => {questions: {@question1.id.to_s => "bcd"}}}}
      assert_response :success
      json = JSON.parse(response.body)
      assert_equal 1, json['people'].count, json.inspect
      assert !json['people'].include?(@person1), json.inspect
    end
  end
end

