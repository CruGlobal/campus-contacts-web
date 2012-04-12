require 'test_helper'

class OrganizationsControllerTest < ActionController::TestCase
  context "when updating org settings" do
    setup do
      @user = Factory(:user_with_auxs)
      sign_in @user
    end
    
    context "and the org settings hash is empty" do
      setup do
        @org = Factory(:organization)
        Factory(:organizational_role, organization: @org, person: @user.person, role: Role.admin)
        
        @request.session[:current_organization_id] = @org.id
      end
      
      should "assign false as the default value for the check box" do
        get :settings
        assert(!assigns(:show_year_in_school))
      end
      
      should "successfully update org settings" do
        post :update_settings, { :show_year_in_school => "on" }
        assert_response(:redirect)
        assert("Successfully updated org settings!",flash[:notice])
        get :settings
        assert(assigns(:show_year_in_school))
      end
      
      should "update the settings" do
        post :update_settings, { :show_year_in_school => "off" }
        assert_response(:redirect)
        assert("Successfully updated org settings!",flash[:notice])
        get :settings
        assert(!assigns(:show_year_in_school))
      end
    end
  end
end
