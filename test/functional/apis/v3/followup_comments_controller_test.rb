require 'test_helper'

class Apis::V3::FollowupCommentsControllerTest < ActionController::TestCase
  setup do
    request.env['HTTP_ACCEPT'] = 'application/json'
    @client = Factory(:client)
    @user = Factory(:user_no_org)
    @client.organization.add_admin(@user.person)
    @followup_comment = Factory(:followup_comment, organization: @client.organization)
  end

  context '.index' do
    should 'return a list of followup_comments' do
      get :index, secret: @client.secret, order: 'created_at'
      assert_response :success
      json = JSON.parse(response.body)
      assert_equal @followup_comment.id, json['followup_comments'].last['id'], json.inspect
    end
  end


  context '.show' do
    should 'return a followup_comment' do
      get :show, id: @followup_comment.id, secret: @client.secret
      json = JSON.parse(response.body)
      assert_equal @followup_comment.id, json['followup_comment']['id']
    end
  end

  context '.create' do
    should 'create and return a followup_comment' do
      assert_difference "FollowupComment.count" do
        post :create, followup_comment: {commenter_id: '1', contact_id: '2'}, secret: @client.secret
      end
      json = JSON.parse(response.body)
      assert_equal 1, json['followup_comment']['commenter_id']
    end
  end

  context '.update' do
    should 'create and return a followup_comment' do
      put :update, id: @followup_comment.id, followup_comment: {commenter_id: '5'}, secret: @client.secret
      json = JSON.parse(response.body)
      assert_equal 5, json['followup_comment']['commenter_id']
    end
  end

  context '.destroy' do
    should 'create and return a followup_comment' do
      assert_difference "FollowupComment.count", -1 do
        delete :destroy, id: @followup_comment.id, secret: @client.secret
      end
    end
  end



end

