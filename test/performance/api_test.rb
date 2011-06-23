require 'performance_test_helper'

class ApiTest < ActionDispatch::PerformanceTest
  # 
  # def setup
  #   @user = User.find(1170780)
  #   @user2 = User.find(193194)
  #   @access_token = Rack::OAuth2::Server::AccessToken.where(:identity => @user.id).first
  # end
    
  def test_request_multiple_people
    @user = User.find(1170780)
    @user2 = User.find(193194)
    @access_token = Rack::OAuth2::Server::AccessToken.where(:identity => @user.id).first
    path="/api/people/#{@user.person.id},#{@user2.person.id}"
    get path, {'access_token' => @access_token.code}
    File.open('/users/Doulos/Desktop/testmytest.log', 'a') do |f2|
      f2.puts "request multiple people\n"
      f2.puts "#{@response.body}\n\n\n"
    end
  end
   #  
   # def test_request_contact_information_associated_with_a_person
   #   set_defaults
   #   path = "/api/contacts/#{@user.person.id}"
   #   get path, {'access_token' => @access_token.code}
   #   File.open('/users/Doulos/Desktop/testmytest.log', 'a') do |f2|
   #     f2.puts "request contact information associated with person\n"
   #     f2.puts "#{@response.body}\n\n\n"
   #   end
   # end
   #   
   # def test_request_friends_of_person
   #   set_defaults
   #   path = "/api/friends/#{@user.person.id}"
   #   get path, {'access_token' => @access_token.code}
   #   File.open('/users/Doulos/Desktop/testmytest.log', 'a') do |f2|
   #     f2.puts "request friends of person\n"
   #     f2.puts "#{@response.body}\n\n\n"
   #   end
   # end
end