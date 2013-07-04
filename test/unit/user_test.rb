require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "missing email from FB raises NoEmailError" do
    assert_raise(NoEmailError) do
      User.find_for_facebook_oauth({"provider"=>"facebook", "uid"=>"1414170167", "info"=>{"name"=>"Brandon Jacobs", "first_name"=>"Brandon", "last_name"=>"Jacobs", "image"=>"http://graph.facebook.com/1414170167/picture?type=square", "urls"=>{"Facebook"=>"http://www.facebook.com/profile.php?id=1414170167"}}, "credentials"=>{"token"=>"AAACad9R36PsBAGZAFY9HUt07rqnkeYWeznTvxdavSDA9HyudrYFMB2pDwTo7dCFTFRADms5Mj5al7FZA190znzDk4fLecZAJNHWspZBflFpzuUD4YORK", "expires_at"=>"1323320331", "expires"=>"true"}, "extra"=>{"raw_info"=>{"id"=>"1414170167", "name"=>"Brandon Jacobs", "first_name"=>"Brandon", "last_name"=>"Jacobs", "link"=>"http://www.facebook.com/profile.php?id=1414170167", "gender"=>"male", "timezone"=>"-5", "locale"=>"en_US", "verified"=>"true", "updated_time"=>"2011-10-17T00:58:48+0000"}}})
    end
  end
  
  test "alias method find by id" do
    u = Factory(:user)
    assert_equal User.find_by_id(u.id), User.find_by_id(u.id)
  end
  
  test "has permission" do
    user = Factory(:user_with_auxs)
    org = Factory(:organization)
    Factory(:organizational_permission, person: user.person, organization: org, permission: Permission.user)
    
    assert user.has_permission?(Permission::USER_ID,  org)
  end
  
  test "merge" do
    user = Factory(:user_with_auxs)
    user2 = Factory(:user_with_auxs)
    assert_equal 2, Person.count
    user.merge(user2)
    assert_equal 1, Person.count
  end
end
