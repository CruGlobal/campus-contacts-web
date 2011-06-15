require 'test_helper'

class ApiHelperTest < ActionView::TestCase
  context "a request that is being authenticated" do
    should "be considered valid" do
      params = {}
      action = "people"
      user = Factory.create :user_with_authentication
      access_token = Factory.create :access_token
      access_token.identity = user.id
      
      x = valid_request?(nil, action, params, access_token) #go ahead and test this with the user action WITHOUT params[:fields]
      assert_equal(x, Apic::API_ALLOWABLE_FIELDS[:v1][:people])
      
      assert_raise(ApiErrors::InvalidRequest) { valid_request?("") }
      
      params[:fields] = Apic::API_ALLOWABLE_FIELDS[:v1][:people].join(',')
      y = valid_request?(nil, action, params, access_token)
      assert_equal(y,Apic::API_ALLOWABLE_FIELDS[:v1][:people])
      
      params[:fields] = "aname,aid,afirst_name,alast_name,abirthday,alocale,alocation,agender,ainterests,afriends,afb_id,apicture"
      assert_raise(ApiErrors::InvalidFieldError) { valid_request?(nil, action, params, access_token) }

      access_token.scope = ""
      params[:fields] = Apic::API_ALLOWABLE_FIELDS[:v1][:people].join(',')
      assert_raise(ApiErrors::IncorrectScopeError) { valid_request?(nil, action, params, access_token) }
  
      params = {}
      assert_raise(ApiErrors::IncorrectScopeError) { valid_request?(nil, action, params, access_token) }
   
      params = {:fields => ""}
      assert_raise(ApiErrors::InvalidFieldError) { valid_request?(nil, action, params, access_token) }
      
    end
  end
end
