require 'test_helper'

class ContactsControllerTest < ActionController::TestCase
  context "Get new before logging in" do
    setup do 
      get :new
    end
    
    should_redirect_to("the login page") { '/users/sign_in' }
  end

end
