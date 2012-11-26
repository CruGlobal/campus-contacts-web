require 'test_helper'

class Apis::V3::SurveysControllerTest < ActionController::TestCase
  setup do
    request.env['HTTP_ACCEPT'] = 'application/json'
    @client = Factory(:client)
    @user = Factory(:user_no_org)
    @client.organization.add_admin(@user.person)
    @survey = Factory(:survey, organization: @client.organization)
  end

  context '.index' do
    should 'return a list of surveys' do
      get :index, secret: @client.secret
      assert_response :success
      json = JSON.parse(response.body)
      assert_equal 1, json['surveys'].length, json.inspect
    end
  end


  context '.show' do
    should 'return a survey' do
      get :show, id: @survey.id, secret: @client.secret
      json = JSON.parse(response.body)
      assert_equal @survey.title, json['survey']['title']
    end
  end

  context '.create' do
    should 'create and return a survey' do
      assert_difference "Survey.count" do
        post :create, survey: {title: 'funk', post_survey_message: 'foo'}, secret: @client.secret
      end
      json = JSON.parse(response.body)
      assert_equal 'funk', json['survey']['title']
    end
  end

  context '.update' do
    should 'create and return a survey' do
      put :update, id: @survey.id, survey: {title: 'funk'}, secret: @client.secret
      json = JSON.parse(response.body)
      assert_equal 'funk', json['survey']['title']
    end
  end

  context '.destroy' do
    should 'create and return a survey' do
      assert_difference "Survey.count", -1 do
        delete :destroy, id: @survey.id, secret: @client.secret
      end
    end
  end



end

