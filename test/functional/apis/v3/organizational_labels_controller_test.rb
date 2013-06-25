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
    @label1 = Factory(:label, organization: @org)

    @org_label = Factory(:organizational_label, organization: @org, person: @person, label: @label)

    @person1 = Factory(:person)
    @org.add_contact(@person1)
    @person2 = Factory(:person)
    @org.add_contact(@person2)
  end

  context '.index' do
    should "return a list of organization's organizational_labels" do
      get :index, secret: @client.secret
      json = JSON.parse(response.body)
      assert_equal @org.organizational_labels.count, json['organizational_labels'].count, json.inspect
    end
  end

  context '.show' do
    should 'return an organizational_label' do
      get :show, id: @org_label.id, secret: @client.secret
      json = JSON.parse(response.body)
      assert_equal @org_label.id, json['organizational_label']['id'], json.inspect
    end
  end

  context '.create' do
    should 'create and return an organizational_label' do
      assert_difference "OrganizationalLabel.count" do
        post :create, organizational_label: {label_id: @label.id, person_id: @person2.id}, secret: @client.secret
      end
      json = JSON.parse(response.body)
      assert_equal @person2.id, json['organizational_label']['person_id'], json.inspect
    end
  end

  context '.update' do
    should 'create and return an organizational_label' do
      put :update, id: @org_label.id, organizational_label: {removed_date: '2013-01-01'}, secret: @client.secret
      json = JSON.parse(response.body)
      assert_equal '2013-01-01', json['organizational_label']['removed_date'], json.inspect
    end
  end

  context '.destroy' do
    should 'create and return an organizational_label' do
      delete :destroy, id: @org_label.id, secret: @client.secret
      @org_label.reload
      assert_equal Date.today, @org_label.removed_date, @org_label.inspect
    end
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

