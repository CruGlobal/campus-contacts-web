require 'test_helper'

class Apis::V3::OrganizationalLabelsControllerTest < ActionController::TestCase
  setup do
    request.env["HTTP_ACCEPT"] = "application/json"
    @org = Factory(:organization)
    @client = Factory(:client, organization: @org)

    # Admin
    @user1 = Factory(:user_api)
    @person1 = @user1.person
    @org.add_admin(@person1)
    @admin_permission = @person1.permission_for_org_id(@org.id)
    @admin_token = Factory(:access_token, identity: @user1.id, client_id: @client.id)

    # User
    @user2 = Factory(:user_api)
    @person2 = @user2.person
    @org.add_user(@person2)
    @user_permission = @person2.permission_for_org_id(@org.id)
    @user_token = Factory(:access_token, identity: @user2.id, client_id: @client.id)

    # No Permission
    @user3 = Factory(:user_api)
    @person3 = @user3.person
    @org.add_contact(@person3)
    @contact_permission = @person3.permission_for_org_id(@org.id)
    @no_permission_token = Factory(:access_token, identity: @user3.id, client_id: @client.id)

    # Other
    @label1 = Factory(:label, organization: @org)
    @label2 = Factory(:label, organization: @org)

    @person = Factory(:person)
    Factory(:email_address, person: @person)
    @org.add_contact(@person)
    @org_label = Factory(:organizational_label, organization: @org, person: @person, label: @label1)

    @another_person = Factory(:person)
    Factory(:email_address, person: @another_person)
    @org.add_contact(@another_person)
    @another_org_label = Factory(:organizational_label, organization: @org, person: @another_person, label: @label1)

    @no_org_person = Factory(:person)
    Factory(:email_address, person: @no_org_person)

    @another_no_org_person = Factory(:person)
    Factory(:email_address, person: @another_no_org_person)
  end

  context ".index" do
    context "ADMIN request" do
      setup do
        @token = @admin_token.code
      end
      should "return a list of organizational_labels" do
        get :index, access_token: @token
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal @org.organizational_labels.count, json['organizational_labels'].count, json.inspect
      end
    end
    context "USER request" do
      setup do
        @token = @user_token.code
      end
      should "return a list of organizational_labels" do
        get :index, access_token: @token
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal @org.organizational_labels.count, json["organizational_labels"].count, json.inspect
      end
    end
    context "NO_PERMISSION request" do
      setup do
        @token = @no_permission_token.code
      end
      should "not return a list of organizational_label" do
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
      should "return an organizational_label" do
        get :show, access_token: @token, id: @org_label.id
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal @org_label.id, json['organizational_label']['id'], json.inspect
      end
    end
    context "USER request" do
      setup do
        @token = @user_token.code
      end
      should "return an organizational_label" do
        get :show, access_token: @token, id: @org_label.id
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal @org_label.id, json['organizational_label']['id'], json.inspect
      end
    end
    context "NO_PERMISSION request" do
      setup do
        @token = @no_permission_token.code
      end
      should "not return an organizational_label" do
        get :show, access_token: @token, id: @org_label.id
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
      should "create and return an organizational_label" do
        assert_difference "OrganizationalLabel.count" do
          post :create, access_token: @token,
                organizational_label: {label_id: @label2.id, person_id: @person.id}
        end
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal @person.id, json['organizational_label']['person_id'], json.inspect
      end
    end
    context "USER request" do
      setup do
        @token = @user_token.code
      end
      should "create and return an organizational_label" do
        assert_difference "OrganizationalLabel.count" do
          post :create, access_token: @token,
                organizational_label: {label_id: @label2.id, person_id: @person.id}
        end
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal @person.id, json['organizational_label']['person_id'], json.inspect
      end
    end
    context "NO_PERMISSION request" do
      setup do
        @token = @no_permission_token.code
      end
      should "not create and return an organizational_label" do
        assert_difference "OrganizationalLabel.count", 0 do
          post :create, access_token: @token,
                organizational_label: {label_id: @label2.id, person_id: @person.id}
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
      should "update and return an organizational_label" do
        put :update, access_token: @token,
            id: @org_label.id, organizational_label: {removed_date: '2013-01-01'}
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal '2013-01-01', json['organizational_label']['removed_date'], json.inspect
      end
    end
    context "USER request" do
      setup do
        @token = @user_token.code
      end
      should "update and return an organizational_label" do
        put :update, access_token: @token,
            id: @org_label.id, organizational_label: {removed_date: '2013-01-01'}
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal '2013-01-01', json['organizational_label']['removed_date'], json.inspect
      end
    end
    context "NO_PERMISSION request" do
      setup do
        @token = @no_permission_token.code
      end
      should "not update and return an organizational_label" do
        put :update, access_token: @token,
            id: @org_label.id, organizational_label: {removed_date: '2013-01-01'}
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
      should "destroy and mark organizational_label as removed" do
        delete :destroy, access_token: @token, id: @org_label.id
        assert_response :success
        @org_label.reload
        assert_not_nil @org_label.removed_date, @org_label.inspect
      end
    end
    context "USER request" do
      setup do
        @token = @user_token.code
      end
      should "destroy and mark organizational_label as removed" do
        delete :destroy, access_token: @token, id: @org_label.id
        assert_response :success
        @org_label.reload
        assert_not_nil @org_label.removed_date, @org_label.inspect
      end
    end
    context "NO_PERMISSION request" do
      setup do
        @token = @no_permission_token.code
      end
      should "not destroy and mark organizational_label as removed" do
        delete :destroy, access_token: @token, id: @org_label.id
        json = JSON.parse(response.body)
        assert_not_nil json["errors"], json.inspect
        @org_label.reload
        assert_nil @org_label.removed_date, @org_label.inspect
      end
    end
  end

  context ".bulk" do
    context "ADMIN request" do
      setup do
        @token = @admin_token.code
      end
      should "create and destroy bulk organizational_labels" do
        get :bulk, access_token: @token,
            filters: {ids: "#{@person.id},#{@another_person.id}"}, add_labels: "#{@label2.id}", remove_labels: "#{@label1.id}"
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal 2, json['people'].count, json.inspect
        assert @person.labels.include?(@label2)
        assert @another_person.labels.include?(@label2)
        assert !@person.labels.include?(@label1)
        assert !@another_person.labels.include?(@label1)
      end
    end
    context "USER request" do
      setup do
        @token = @user_token.code
      end
      should "create and destroy bulk organizational_labels" do
        get :bulk, access_token: @token,
            filters: {ids: "#{@person.id},#{@another_person.id}"}, add_labels: "#{@label2.id}", remove_labels: "#{@label1.id}"
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal 2, json['people'].count, json.inspect
        assert @person.labels.include?(@label2)
        assert @another_person.labels.include?(@label2)
        assert !@person.labels.include?(@label1)
        assert !@another_person.labels.include?(@label1)
      end
    end
    context "NO_PERMISSION request" do
      setup do
        @token = @no_permission_token.code
      end
      should "not create and destroy bulk organizational_labels" do
        get :bulk, access_token: @token,
            filters: {ids: "#{@person.id},#{@another_person.id}"}, add_labels: "#{@label2.id}", remove_labels: "#{@label1.id}"
        json = JSON.parse(response.body)
        assert_not_nil json["errors"], json.inspect
        assert @person.labels.include?(@label1)
        assert @another_person.labels.include?(@label1)
        assert !@person.labels.include?(@label2)
        assert !@another_person.labels.include?(@label2)
      end
    end
  end

  context ".bulk_create" do
    context "ADMIN request" do
      setup do
        @token = @admin_token.code
      end
      should "create bulk organizational_labels" do
        get :bulk_create, access_token: @token,
            filters: {ids: "#{@person.id},#{@another_person.id}"}, labels: "#{@label2.id}"
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal 2, json['people'].count, json.inspect
        assert @person.labels.include?(@label1)
        assert @another_person.labels.include?(@label1)
        assert @person.labels.include?(@label2)
        assert @another_person.labels.include?(@label2)
      end
    end
    context "USER request" do
      setup do
        @token = @user_token.code
      end
      should "create bulk organizational_labels" do
        get :bulk_create, access_token: @token,
            filters: {ids: "#{@person.id},#{@another_person.id}"}, labels: "#{@label2.id}"
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal 2, json['people'].count, json.inspect
        assert @person.labels.include?(@label1)
        assert @another_person.labels.include?(@label1)
        assert @person.labels.include?(@label2)
        assert @another_person.labels.include?(@label2)
      end
    end
    context "NO_PERMISSION request" do
      setup do
        @token = @no_permission_token.code
      end
      should "not create bulk organizational_labels" do
        get :bulk_create, access_token: @token,
            filters: {ids: "#{@person.id},#{@another_person.id}"}, labels: "#{@label2.id}"
        json = JSON.parse(response.body)
        assert_not_nil json["errors"], json.inspect
        assert @person.labels.include?(@label1)
        assert @another_person.labels.include?(@label1)
        assert !@person.labels.include?(@label2)
        assert !@another_person.labels.include?(@label2)
      end
    end
  end

  context ".bulk_destroy" do
    context "ADMIN request" do
      setup do
        @token = @admin_token.code
      end
      should "destroy bulk organizational_labels" do
        get :bulk_destroy, access_token: @token,
            filters: {ids: "#{@person.id},#{@another_person.id}"}, labels: "#{@label1.id}"
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal 2, json['people'].count, json.inspect
        assert !@person.labels.include?(@label1)
        assert !@another_person.labels.include?(@label1)
        assert !@person.labels.include?(@label2)
        assert !@another_person.labels.include?(@label2)
      end
    end
    context "USER request" do
      setup do
        @token = @user_token.code
      end
      should "destroy bulk organizational_labels" do
        get :bulk_destroy, access_token: @token,
            filters: {ids: "#{@person.id},#{@another_person.id}"}, labels: "#{@label1.id}"
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal 2, json['people'].count, json.inspect
        assert !@person.labels.include?(@label1)
        assert !@another_person.labels.include?(@label1)
        assert !@person.labels.include?(@label2)
        assert !@another_person.labels.include?(@label2)
      end
    end
    context "NO_PERMISSION request" do
      setup do
        @token = @no_permission_token.code
      end
      should "destroy bulk organizational_labels" do
        get :bulk_destroy, access_token: @token,
            filters: {ids: "#{@person.id},#{@another_person.id}"}, labels: "#{@label1.id}"
        json = JSON.parse(response.body)
        assert_not_nil json["errors"], json.inspect
        assert @person.labels.include?(@label1)
        assert @another_person.labels.include?(@label1)
        assert !@person.labels.include?(@label2)
        assert !@another_person.labels.include?(@label2)
      end
    end
  end
end