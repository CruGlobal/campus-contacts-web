require 'test_helper'

class Apis::V3::OrganizationalLabelsControllerTest < ActionController::TestCase
  setup do
    request.env['HTTP_ACCEPT'] = 'application/json'
    @client = Factory(:client)
    @user = Factory(:user_no_org)
    @person = @user.person
    @org = @client.organization

    @org.add_admin(@person)

    @permission = @user.person.permission_for_org_id(@org.id)
    @permission1 = Factory(:permission)
    @label = Factory(:label, organization: @org)

    Factory(:organizational_label, organization: @org, person: @person, label: @label)

    @person1 = Factory(:person)
    @org.add_contact(@person1)
    @person2 = Factory(:person)
    @org.add_contact(@person2)
    @label1 = Factory(:label, organization: @org)
  end

  context '.bulk' do
    should 'create and destroy bulk organizational_labels' do
      get :bulk, filters: {ids: "#{@person1.id},#{@person2.id}"}, add_labels: "#{@label1.id}", remove_labels: "#{@label.id}", secret: @client.secret, order: 'created_at'
      assert_response :success
      json = JSON.parse(response.body)
      assert_equal 2, json['organizational_labels'].count, json.inspect
      assert @person1.labels.include?(@label1), @person1.labels.inspect
      assert @person2.labels.include?(@label1), @person2.labels.inspect
      assert !@person1.labels.include?(@label), @person1.labels.inspect
      assert !@person2.labels.include?(@label), @person2.labels.inspect
    end
  end

  context '.bulk_create' do
    should 'create organizational_labels' do
      get :bulk_create, filters: {ids: "#{@person.id},#{@person1.id},#{@person2.id}"}, labels: "#{@label.id}", secret: @client.secret
      assert_response :success
      json = JSON.parse(response.body)
      assert_equal 3, json['organizational_labels'].count, json.inspect
      assert @person.labels.include?(@label)
      assert @person1.labels.include?(@label)
      assert @person2.labels.include?(@label)
    end
    should 'create bulk organizational_labels' do
      get :bulk_create, filters: {ids: "#{@person.id},#{@person1.id},#{@person2.id}"}, labels: "#{@label.id},#{@label1.id}", secret: @client.secret
      assert_response :success
      json = JSON.parse(response.body)
      assert_equal 3, json['organizational_labels'].count, json.inspect
      assert @person.labels.include?(@label)
      assert @person1.labels.include?(@label)
      assert @person2.labels.include?(@label)
      assert @person.labels.include?(@label1)
      assert @person1.labels.include?(@label1)
      assert @person2.labels.include?(@label1)
    end
  end


  context '.bulk_destroy' do
    should 'destroy bulk organizational_labels' do
      Factory(:organizational_label, organization: @org, person: @person1, label: @label)
      Factory(:organizational_label, organization: @org, person: @person2, label: @label)
      assert @person1.labels.include?(@label)
      assert @person2.labels.include?(@label)

      get :bulk_destroy, filters: {ids: "#{@person1.id},#{@person2.id}"}, labels: "#{@label.id}", secret: @client.secret
      assert_response :success
      json = JSON.parse(response.body)
      assert_equal 2, json['organizational_labels'].count, json.inspect
      assert !@person1.labels.include?(@label), @person1.labels.inspect
      assert !@person2.labels.include?(@label), @person2.labels.inspect
    end
  end
end

