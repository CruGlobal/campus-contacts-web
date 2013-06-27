require 'test_helper'

class Apis::V3::FollowupCommentsControllerTest < ActionController::TestCase
  setup do
    request.env['HTTP_ACCEPT'] = 'application/json'
    @client = Factory(:client)
    @user = Factory(:user_no_org)
    @org = @client.organization
    @person = @user.person
    @person1 = Factory(:person)
    @person2 = Factory(:person)

    @client.organization.add_admin(@person)
    @client.organization.add_user(@person1)
    @client.organization.add_user(@person2)

    @followup_comment = Factory(:interaction_type, organization_id: 0, i18n: 'comment')
    @followup_comment = Factory(:interaction, organization: @org, receiver: @person, creator: @person1)
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
      assert_equal @followup_comment.id, json['followup_comment']['id'], json.inspect
    end
  end

  context '.create' do
    should 'create and return a followup_comment' do
      assert_difference "Interaction.count" do
        post :create, followup_comment: {commenter_id: @person1, contact_id: @person2}, secret: @client.secret
      end
      json = JSON.parse(response.body)
      assert_equal @person1.id, json['followup_comment']['commenter_id'], json.inspect
      assert_equal @person2.id, json['followup_comment']['contact_id'], json.inspect
    end
  end

  context '.update' do
    should 'update and return a followup_comment' do
      assert_equal @person1.id, @followup_comment.created_by_id, @followup_comment.inspect
      put :update, id: @followup_comment.id, followup_comment: {commenter_id: @person2}, secret: @client.secret
      json = JSON.parse(response.body)
      assert_equal @person2.id, json['followup_comment']['commenter_id'], json.inspect
    end
  end

  context '.destroy' do
    should 'update and return a followup_comment' do
      assert_difference "FollowupComment.count", 0 do
        delete :destroy, id: @followup_comment.id, secret: @client.secret
      end
      @followup_comment.reload
      assert_not_nil @followup_comment.deleted_at, @followup_comment.inspect
    end
  end



end

