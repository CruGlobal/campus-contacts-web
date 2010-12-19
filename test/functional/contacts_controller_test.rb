require 'test_helper'

class ContactsControllerTest < ActionController::TestCase
  context "Before logging in" do
    should "redirect on new" do
      get :new
      assert_redirected_to '/users/sign_in'
    end
    
    should "redirect on update" do
      @contact = Factory(:person)
      put :update, :id => @contact.id
      assert_redirected_to '/users/sign_in'
    end
    
    should "redirect for thanks" do
      get :thanks
      assert_redirected_to '/users/sign_in'
    end
  end

  context "After logging in" do
    setup do
      @user = Factory(:user)
      sign_in @user
    end
    context "new with received_sms_id from mobile" do
      setup do
        @sms = Factory(:received_sms)
        get :new, :received_sms_id => Base62.encode(@sms.id), :format => 'mobile'
        @person = assigns(:person)
      end
    
      should assign_to(:person)
      should respond_with(:success)
      should "update person with sms phone number" do
        assert(@person.phone_numbers.detect {|p| p.number_with_country_code == @sms.phone_number}, 'phone number wasn\'t saved')
      end
      should "associate the sms with the person" do
        @sms.reload
        assert(@sms.person == @person, "Sms wasn't assiged to person properly")
      end
    end
    
    context "when posting an update with good parameters" do
      setup do
        @contact = Factory(:person)
        put :update, :id => @contact.id, :format => 'mobile'
      end
      should render_template('thanks')
    end
    
    context "when posting an update with bad parameters" do
      setup do
        @contact = Factory(:person)
        put :update, :id => @contact.id, :format => 'mobile', :person => {:firstName => ''}
      end
      should render_template('new')
    end
    
    should "show thanks" do
      get :thanks, :format => 'mobile'
      assert_response :success, @response.body
    end

  end
end
