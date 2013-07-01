require 'test_helper'
include ApiTestHelper

class ApiV1CommentsTest < ActionDispatch::IntegrationTest
  context "the api" do
    setup do
      setup_api_env()
    end

    should "be able to add a comment to a contact" do
      path = "/api/followup_comments/"
      assert_equal(FollowupComment.all.count, 0)
      assert_equal(Rejoicable.all.count, 0)
      json = ActiveSupport::JSON.encode({followup_comment: {:organization_id => @user3.person.primary_organization.id, :contact_id=>@user2.person.id, :commenter_id=>@user.person.id, :status=>"do_not_contact", :comment=>"Testing the comment system."}, rejoicables: ["spiritual_conversation", "prayed_to_receive", "gospel_presentation"]})
      post path, {'access_token' => @access_token3.code, 'json' => json }
      assert_equal(FollowupComment.all.count, 1)
      assert_equal(Rejoicable.all.count,3)
      assert_equal(FollowupComment.all.first.comment, "Testing the comment system.")
    end

    should "be denied adding a comment to a contact with improper scope" do
      @access_token3.update_attributes(scope: "contacts userinfo")
      path = "/api/followup_comments/"
      json = ActiveSupport::JSON.encode({followup_comment: {:organization_id => @user3.person.primary_organization.id, :contact_id=>@user2.person.id, :commenter_id=>@user.person.id, :status=>"do_not_contact", :comment=>"Testing the comment system."}, rejoicables: ["spiritual_conversation", "prayed_to_receive", "gospel_presentation"]})
      post path, {'access_token' => @access_token3.code, 'json' => json }
      @json = ActiveSupport::JSON.decode(@response.body)

      assert_equal(@json['error']['code'],"55")
    end

    should "return a json error when invalid JSON is sent to the create action" do
      path = "/api/followup_comments/"
      json = '{blah":aoeuaoeu"}'
      post path, {'access_token' => @access_token3.code, 'json' => json }
      @json = ActiveSupport::JSON.decode(@response.body)
      assert_equal(@json['error']['code'], "33")
    end

    should "return a json error when create params are incorrect" do
      #raise error if no org_id
      path = "/api/followup_comments/"
      json = ActiveSupport::JSON.encode({rejoicables: ["spiritual_conversation", "prayed_to_receive", "gospel_presentation"]})
      post path, {'access_token' => @access_token3.code, 'json' => json }
      @json = ActiveSupport::JSON.decode(@response.body)
      assert_equal(@json['error']['code'], "28")

      #raise error if no rejoicables
      json = ActiveSupport::JSON.encode({followup_comment: {:organization_id => '@user3.person.primary_organization.id', :contact_id=>@user2.person.id, :commenter_id=>@user.person.id, :status=>"do_not_contact", :comment=>"Testing the comment system."}})
      post path, {'access_token' => @access_token3.code, 'json' => json }
      @json = ActiveSupport::JSON.decode(@response.body)
      assert_equal(@json['error']['code'], "28")
    end

    should "be able to get the followup comments" do
      #create a few test comments
      path = "/api/v1/followup_comments/"
      json = ActiveSupport::JSON.encode({followup_comment: {:organization_id => @user3.person.primary_organization.id, :contact_id=>@user2.person.id, :commenter_id=>@user.person.id, :status=>"do_not_contact", :comment=>"Testing the comment system."}, rejoicables: ["spiritual_conversation", "prayed_to_receive", "gospel_presentation"]})
      post path, {'access_token' => @access_token3.code, 'json' => json }
      path = "/api/v1/followup_comments/#{@user2.person.id}"
      get path, {'access_token' => @access_token3.code}
      @json = ActiveSupport::JSON.decode(@response.body)
      f1 = FollowupComment.first

      followup_comment_test(@json[0]['followup_comment'], f1, @user2.person, @user.person)
    end

    should "be able to delete a followup comment" do
      path = "/api/followup_comments/"
      json = ActiveSupport::JSON.encode({followup_comment: {:organization_id => @user3.person.primary_organization.id, :contact_id=>@user2.person.id, :commenter_id=>@user.person.id, :status=>"do_not_contact", :comment=>"Testing the comment system."}, rejoicables: ["spiritual_conversation", "prayed_to_receive", "gospel_presentation"]})
      post path, {'access_token' => @access_token3.code, 'json' => json }

      assert_equal(FollowupComment.where(contact_id: @user2.person.id).count, 1)

      path = "/api/followup_comments/#{FollowupComment.where(:contact_id => @user2.person.id).first.id}"
      delete path, {'access_token' => @access_token3.code}

      assert_equal(FollowupComment.where(contact_id: @user2.person.id).count, 0)
    end

    should "return a json error when a non-integer id is specified on a followup comment delete action" do
      path = "/api/followup_comments/aoeu"
      delete path, {'access_token' => @access_token3.code}
      @json = ActiveSupport::JSON.decode(@response.body)
      assert_equal(@json['error']['code'], "34")
    end

    should "return a json error when the identity of the access_token is not a leader/admin in the current organization" do
      path = "/api/followup_comments/"
      json = ActiveSupport::JSON.encode({followup_comment: {:organization_id => @user3.person.primary_organization.id, :contact_id=>@user2.person.id, :commenter_id=>@user.person.id, :status=>"do_not_contact", :comment=>"Testing the comment system."}, rejoicables: ["spiritual_conversation", "prayed_to_receive", "gospel_presentation"]})
      post path, {'access_token' => @access_token3.code, 'json' => json }

      assert_equal(FollowupComment.where(contact_id: @user2.person.id).count, 1)

      @user3.person.organizational_permissions.first.update_attributes(permission_id: Permission::NO_PERMISSIONS_ID)
      path = "/api/followup_comments/#{FollowupComment.where(:contact_id => @user2.person.id).first.id}"
      delete path, {'access_token' => @access_token3.code}
      @json = ActiveSupport::JSON.decode(@response.body)

      assert ["35","32"].include?(@json['error']['code']), @json['error'].inspect
    end

    should "return a json error when the identity of the access_token is a leader in the current organization and attempts to delete a comment other than their own" do
      path = "/api/followup_comments/"
      json = ActiveSupport::JSON.encode({followup_comment: {:organization_id => @user3.person.primary_organization.id, :contact_id=>@user2.person.id, :commenter_id=>@user.person.id, :status=>"do_not_contact", :comment=>"Testing the comment system."}, rejoicables: ["spiritual_conversation", "prayed_to_receive", "gospel_presentation"]})
      post path, {'access_token' => @access_token3.code, 'json' => json }

      assert_equal(FollowupComment.where(contact_id: @user2.person.id).count, 1)

      @user3.person.organizational_permissions.first.update_attributes(permission_id: Permission::USER_ID)
      path = "/api/followup_comments/#{FollowupComment.where(:contact_id => @user2.person.id).first.id}"
      delete path, {'access_token' => @access_token3.code}
      @json = ActiveSupport::JSON.decode(@response.body)

      assert_equal(@json['error']['code'], "35")
    end
  end
end
