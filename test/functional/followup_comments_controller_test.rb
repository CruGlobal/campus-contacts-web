require 'test_helper'

class FollowupCommentsControllerTest < ActionController::TestCase
  context "Search comments" do
  
    setup do
      @user = Factory(:user_with_auxs)
      sign_in @user
      
      @org = Factory(:organization)
      @org.add_admin(@user.person)
      @sub_org = Factory(:organization, parent: @org)
    end
    
    context "Admin searches for comments" do
      setup do
        @person1 = Factory(:person)
        @person2 = Factory(:person)
        @person3 = Factory(:person)
        @person4 = Factory(:person)
        @person5 = Factory(:person)
        @person6 = Factory(:person)
        
        Factory(:followup_comment, organization: @org, contact: @person1, commenter: @user.person,
        comment: "Hi, this is a comment.")
        Factory(:followup_comment, organization: @org, contact: @person2, commenter: @user.person,
        comment: "This is a slightly different comment.")
        Factory(:followup_comment, organization: @org, contact: @person3, commenter: @user.person,
        comment: "An entirely different comment, trying to keep it different")
        Factory(:followup_comment, organization: @sub_org, contact: @person4, commenter: @user.person,
        comment: "Could be a different comment, but not really.")
        Factory(:followup_comment, organization: @sub_org, contact: @person5, commenter: @user.person,
        comment: "Slightly change this comment, but it's not that different that the other one.")
        Factory(:followup_comment, organization: @sub_org, contact: @person6, commenter: @user.person,
        comment: "This comment doesn't really make any sense. Microwave.")
      end
      
      should "get correct number of comments, with no parameters from top org" do
        @request.session[:current_organization_id] = @org.id
        get :index
        assert_response :success
        assert_not_nil assigns(:comments)
        assert_equal(assigns(:comments).count, 3)
      end
      
      should "get correct number of comments, with no parameters from sub org" do
        @request.session[:current_organization_id] = @sub_org.id
        get :index
        assert_response :success
        assert_not_nil assigns(:comments)
        assert_equal(assigns(:comments).count, 3)
      end
      
      should "search and return the correct number of comments from top org" do
        @request.session[:current_organization_id] = @org.id
        get :index, { :query => "comment" }
        assert_response :success
        assert_not_nil assigns(:comments)
        assert_equal(assigns(:comments).count, 3)
        
        get :index, { :query => "different" }
        assert_response :success
        assert_not_nil assigns(:comments)
        assert_equal(assigns(:comments).count, 2)
        
        get :index, { :query => "entirely" }
        assert_response :success
        assert_not_nil assigns(:comments)
        assert_equal(assigns(:comments).count, 1)
      end
      
      should "search and return the correct number of comments from top org" do
        @request.session[:current_organization_id] = @sub_org.id
        get :index, { :query => "comment" }
        assert_response :success
        assert_not_nil assigns(:comments)
        assert_equal(assigns(:comments).count, 3)
        
        get :index, { :query => "different" }
        assert_response :success
        assert_not_nil assigns(:comments)
        assert_equal(assigns(:comments).count, 2)
        
        get :index, { :query => "microwave" }
        assert_response :success
        assert_not_nil assigns(:comments)
        assert_equal(assigns(:comments).count, 1)
      end   
    end

  end
end
