require 'test_helper'

class ApiHelperTest < ActionView::TestCase
  context "a request that is being authenticated" do
    should "be considered valid" do
      params = {}
      action = "user"
      user = Factory.create :user_with_authentication
      access_token = Factory.create :access_token
      access_token.identity = user.userID
      
      x = valid_request?(nil, action, params, access_token) #go ahead and test this with the user action WITHOUT params[:fields]
      assert_equal(x, Apic::API_ALLOWABLE_FIELDS[:user])
      
      assert_raise(ApiErrors::InvalidRequest) { valid_request?("") }
      
      params[:fields]="name,id,first_name,last_name,birthday,locale,location,gender,interests,friends,fb_id,picture"
      y = valid_request?(nil, action, params, access_token)
      assert_equal(y,params[:fields].split(','))
      
      params[:fields]="aname,aid,afirst_name,alast_name,abirthday,alocale,alocation,agender,ainterests,afriends,afb_id,apicture"
      assert_raise(ApiErrors::InvalidFieldError) { valid_request?(nil, action, params, access_token) }

      access_token.scope = ""
      params[:fields]="name,id,first_name,last_name,birthday,locale,location,gender,interests,friends,fb_id,picture"
      assert_raise(ApiErrors::IncorrectScopeError) { valid_request?(nil, action, params, access_token) }
  
      params = {}
      assert_raise(ApiErrors::IncorrectScopeError) { valid_request?(nil, action, params, access_token) }
   
      params = {:fields => ""}
      assert_raise(ApiErrors::InvalidFieldError) { valid_request?(nil, action, params, access_token) }
      
    end
  end
end
