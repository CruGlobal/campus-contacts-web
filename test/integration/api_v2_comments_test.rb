require 'test_helper'
include ApiTestHelper

class ApiV2CommentsTest < ActionDispatch::IntegrationTest
  context "the api" do
    setup do
      setup_api_env()
    end

    should "be able to get the followup comments" do
      #create a few test comments
      path = "/api/followup_comments/"
      json = ActiveSupport::JSON.encode({followup_comment: {:organization_id => @user3.person.primary_organization.id, :contact_id=>@user2.person.id, :commenter_id=>@user.person.id, :status=>"do_not_contact", :comment=>"Testing the comment system."}, rejoicables: ["spiritual_conversation"]})
      post path, {'access_token' => @access_token3.code, 'json' => json }, {:accept => 'application/vnd.missionhub-v2+json'}
      path = "/api/followup_comments/#{@user2.person.id}"
      get path, {'access_token' => @access_token3.code}, {:accept => 'application/vnd.missionhub-v2+json'}
      @json = ActiveSupport::JSON.decode(@response.body)
      f1 = Interaction.first
      followup_comment_test(@json['followup_comments'][0]['followup_comment'], f1, @user2.person, @user.person)
    end

  end
end