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

      xhr :post, :create, email: @user.email, person_id: @contact.id

      assert_response :success
    end

    context "create bulk vcard" do
      setup do
        @contact = Factory(:person)
        @contact2 = Factory(:person)
      end

      should 'and send to many' do
        @user.person.organizations.first.add_contact(@contact)
        @user.person.organizations.first.add_contact(@contact2)
        ids = "#{@contact.id}, #{@contact2.id}"
        xhr :get, :bulk_create, ids: ids, email: @user.email, note: "Vcard"
        assert_response :success
      end

      should 'and send to single' do
        @user.person.organizations.first.add_contact(@contact)
        xhr :get, :bulk_create, ids: [@contact.id], email: @user.email, note: "Vcard"
        assert_response :success
      end

      should 'and to download' do
        @user.person.organizations.first.add_contact(@contact)
        @user.person.organizations.first.add_contact(@contact2)
        xhr :get, :bulk_create, ids: [@contact.id, @contact2.id]
        assert_response :success
      end
    end

  end
end
