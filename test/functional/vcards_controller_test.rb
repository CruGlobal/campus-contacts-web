require 'test_helper'

class VcardsControllerTest < ActionController::TestCase
  
  context "After logging in a person with orgs" do
    setup do
      @user = Factory(:user_with_auxs)  #user with a person object
      sign_in @user
      @keyword = Factory.create(:sms_keyword)
    end
    
    
    should 'send single vcard' do        
      @contact = Factory(:person)
            
      xhr :post, :create, send_contact_info_email: @contact.email, person_id: @contact.id
      
      assert_response :success   
    end
    
    should 'send bulk vcard' do 
      
      @contact = Factory(:person)
      @contact2 = Factory(:person)
      
      @user.person.organizations.first.add_contact(@contact)                
      @user.person.organizations.first.add_contact(@contact2)                      
         
      xhr :get, :bulk_create, ids: [@contact.id, @contact2.id]
    
      assert_response :success  
    end

  end
    
    
end
