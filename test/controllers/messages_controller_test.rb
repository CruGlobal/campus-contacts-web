require 'test_helper'

class MessagesControllerTest < ActionController::TestCase
  setup do
    @user1, @org = admin_user_login_with_org
    @user2 = FactoryGirl.create(:user_with_auxs)

    @contact1 = @user1.person
    @contact2 = @user2.person

    @org.add_contact(@contact1)
    @org.add_contact(@contact2)
  end

  context 'Sent messages ' do
    should 'return all messages' do
      Message.create(person_id: @contact1.id, receiver_id: @contact2.id, from: @contact1.email, to: @contact2.email, organization_id: @org.id, message: 'Hello', sent_via: 'email')
      xhr :post, :sent_messages
      assert_equal 1, assigns(:messages).count
    end
  end
end
