require 'test_helper'

class ApiFlowsTest < ActionDispatch::IntegrationTest

  context "a client" do
    setup do
      @user = Factory.create(:user_with_auxs)
      @user2 = Factory.create(:user2_with_auxs)
      @user2.person.update_attributes(:firstName => "Test", :lastName => "Useroo")
      @user2.person.organization_memberships.destroy_all
      @user2.person.organization_memberships.create(:organization_id => @user.person.primary_organization.id, :person_id => @user2.person.id, :primary => 1, :role => "leader", :followup_status => "contacted")
      ContactAssignment.create(:assigned_to_id => @user.person.id, :person_id => @user2.person.id, :organization_id => @user.person.organizations.first.id)
      ContactAssignment.create(:assigned_to_id => @user2.person.id, :person_id => @user.person.id, :organization_id => @user.person.organizations.first.id)
      @access_token = Factory.create(:access_token, :identity => @user.id)
      @access_token2 = Factory.create(:access_token, :identity => @user2.id, :code => "aoeuaocnpganoeuhnh234hnaeu")
    end
    
    should "be able to request person information" do
      path = "/api/people/#{@user.person.id}"
      get path, {'access_token' => @access_token.code}
      assert_response :success, @response.body
      @json = ActiveSupport::JSON.decode(@response.body)
      
      person_full_test(@json[0], @user, @user2)
    end
    
    should "be able to request person information with fields" do
      path = "/api/people/#{@user.person.id}"
      get path, {'access_token' => @access_token.code, 'fields' => "first_name,last_name,name,id,birthday,fb_id,picture,gender,education,interests,id,locale,location,assignment,request_org_id,organization_membership,status"}
      assert_response :success, @response.body
      @json = ActiveSupport::JSON.decode(@response.body)
      
      person_full_test(@json[0], @user, @user2)
    end
    
    should "be able to get person friends" do
      path = "/api/friends/#{@user.person.id}"
      get path, {'access_token' => @access_token.code}
      assert_response :success, @response.body
      @json = ActiveSupport::JSON.decode(@response.body)

      person_mini_test(@json[0]['person'],@user)
      assert_equal(@json[0]['friends'].length, 3)
      friend_test(@json[0]['friends'][0], @user.person.friends.first)
    end
    
    context "with version 1 specified" do
      should "be able to request person information" do
        path = "/api/v1/people/#{@user.person.id}"
        get path, {'access_token' => @access_token.code}
        assert_response :success, @response.body
        @json = ActiveSupport::JSON.decode(@response.body)

        person_full_test(@json[0], @user, @user2)
      end
    
      should "be able to request person information with fields" do
        path = "/api/v1/people/#{@user.person.id}"
        get path, {'access_token' => @access_token.code, 'fields' => "first_name,last_name,name,id,birthday,fb_id,picture,gender,education,interests,id,locale,location,assignment,request_org_id,organization_membership,status"}
        assert_response :success, @response.body
        @json = ActiveSupport::JSON.decode(@response.body)
         
        person_full_test(@json[0], @user, @user2)
      end
    
      should "be able to get person friends" do
        path = "/api/v1/friends/#{@user.person.id}"
        get path, {'access_token' => @access_token.code}
        assert_response :success, @response.body
        @json = ActiveSupport::JSON.decode(@response.body)
        
        person_mini_test(@json[0]['person'],@user)
        assert_equal(@json[0]['friends'].length, 3)
        friend_test(@json[0]['friends'][0], @user.person.friends.first)
      end
    end
  end
  
  context "a client" do 
    setup do
      @user = Factory.create(:user_with_auxs)
      @user2 = Factory.create(:user2_with_auxs)
      @user2.person.update_attributes(:firstName => "Test", :lastName => "Useroo")
      temp_org = @user.person.primary_organization.id
      @user2.person.organization_memberships.destroy_all
      @user.person.organization_memberships.destroy_all
      @user2.person.organization_memberships.create(:organization_id => temp_org, :person_id => @user2.person.id, :primary => 1, :role => "leader", :followup_status => "contacted")
      @user.person.organization_memberships.create(:organization_id => temp_org, :person_id => @user.person.id, :primary => 1, :role => "leader", :followup_status => "attempted_contact")
      
      ContactAssignment.create(:assigned_to_id => @user.person.id, :person_id => @user2.person.id, :organization_id => @user.person.organizations.first.id)
      ContactAssignment.create(:assigned_to_id => @user2.person.id, :person_id => @user.person.id, :organization_id => @user.person.organizations.first.id)
      @access_token = Factory.create(:access_token, :identity => @user.id)
      @access_token2 = Factory.create(:access_token, :identity => @user2.id, :code => "aoeuaocnpganoeuhnh234hnaeu")
      @organization = Factory(:organization)
      @keyword = Factory(:approved_keyword, :organization => @user.person.organizations.first)
      @firstNameQ = Factory(:element)
      @keyword.question_page.elements << @firstNameQ  
      @questions = @keyword.question_sheet.questions
      @answer_sheet = Factory(:answer_sheet, :question_sheet => @keyword.question_sheet, :person => @user.person)
      @answer_sheet2 = Factory(:answer_sheet, :question_sheet => @keyword.question_sheet, :person => @user2.person)
      @answer_to_choice = Factory(:answer_1, :answer_sheet => @answer_sheet, :question => @questions.first)
      @answer_to_choice2 = Factory(:answer_1, :answer_sheet => @answer_sheet2, :question => @questions.first)
    end
    
    should "be able to view their contacts" do
      path = "/api/contacts/"
      get path, {'access_token' => @access_token.code}
      assert_response :success, @response.body
      @json = ActiveSupport::JSON.decode(@response.body)
      person_basic_test(@json[0]['person'],@user,@user2)
      person_basic_test(@json[1]['person'],@user2,@user)
    end
    
    should "be able to view their contacts filtered by gender=male" do
      path = "/api/contacts.json?filters=gender&values=male"
      get path, {'access_token' => @access_token.code}
      assert_response :success, @response.body
      @json = ActiveSupport::JSON.decode(@response.body)
      assert_equal(@json.length,2)
      @json.each do |person|
        assert_equal(person['person']['gender'],'male')
        assert_not_equal(person['person']['gender'],'female')
      end
    end
    
    should "be able to view their contacts filtered by gender=female" do
      path = "/api/contacts.json?filters=gender&values=female"
      get path, {'access_token' => @access_token.code}
      assert_response :success, @response.body
      @json = ActiveSupport::JSON.decode(@response.body)
      assert_equal(@json.length,0)
      
      @user.person.update_attributes(:gender => 'female')
      @user2.person.update_attributes(:gender => 'female')
      get path, {'access_token' => @access_token.code}
      assert_response :success, @response.body
      @json = ActiveSupport::JSON.decode(@response.body)
      assert_equal(@json.length,2)
      @json.each do |person|
        assert_equal(person['person']['gender'],'female')
        assert_not_equal(person['person']['gender'],'male')
      end
    end
    
    should "be able to view their contacts with start and limit" do
      path = "/api/contacts.json?limit=1&start=0"
      get path, {'access_token' => @access_token.code}
      assert_response :success, @response.body
      @json = ActiveSupport::JSON.decode(@response.body)
      
      assert_equal(@json.length, 1)
      person_basic_test(@json[0]['person'],@user,@user2) 
      
      path = "/api/contacts.json?limit=1&start=1"
      get path, {'access_token' => @access_token.code}
      assert_response :success, @response.body
      @json = ActiveSupport::JSON.decode(@response.body)
      
      assert_equal(@json.length, 1)
      person_basic_test(@json[0]['person'],@user2,@user)     
      
      #raise an error when no limit with start
      path = "/api/contacts.json?start=1"
      get path, {'access_token' => @access_token.code}
      assert_response :success, @response.body
      @json = ActiveSupport::JSON.decode(@response.body)
      
      assert_equal(@json['error']['code'],"29")

      path = "/api/contacts.json?limit=1"
      get path, {'access_token' => @access_token.code}
      assert_response :success, @response.body
      @json = ActiveSupport::JSON.decode(@response.body)
      assert_equal(@json.length, 1)
    end
    
    should "be able to view their contacts filtered by status=contacted" do
      path = "/api/contacts.json?filters=status&values=contacted"
      get path, {'access_token' => @access_token.code}
      assert_response :success, @response.body
      @json = ActiveSupport::JSON.decode(@response.body)
      assert_equal(@json.length,1)
      person_basic_test(@json[0]['person'],@user2,@user)
      
      @user.person.organization_memberships.where(:organization_id => @user.person.primary_organization.id).first.update_attributes(:followup_status => 'attempted_contact')
      @user2.person.organization_memberships.where(:organization_id => @user.person.primary_organization.id).first.update_attributes(:followup_status => 'attempted_contact')
      path = "/api/contacts.json?filters=status&values=contacted"
      get path, {'access_token' => @access_token.code}
      assert_response :success, @response.body
      @json = ActiveSupport::JSON.decode(@response.body)
      assert_equal(@json.length,0)
      
      path = "/api/contacts.json?filters=status&values=attempted_contact"
      get path, {'access_token' => @access_token.code}
      assert_response :success, @response.body
      @json = ActiveSupport::JSON.decode(@response.body)
      assert_equal(@json.length,2)
      
      path = "/api/contacts.json?filters=status,gender&values=attempted_contact,female"
      get path, {'access_token' => @access_token.code}
      assert_response :success, @response.body
      @json = ActiveSupport::JSON.decode(@response.body)
      assert_equal(@json.length,0)
    end    
    
    should "be able to view their contacts with sorting" do
      path = "/api/contacts.json?sort=time&direction=desc"
      @user2.person.answer_sheets.first.update_attributes(:created_at => 2.days.ago)
      get path, {'access_token' => @access_token.code}
      assert_response :success, @response.body
      @json = ActiveSupport::JSON.decode(@response.body)
      
      assert_equal(@json.length, 2)
      person_mini_test(@json[0]['person'],@user) 

      path = "/api/contacts.json?sort=time&direction=asc"
      @user2.person.answer_sheets.first.update_attributes(:created_at => 2.days.ago)
      get path, {'access_token' => @access_token.code}
      assert_response :success, @response.body
      @json = ActiveSupport::JSON.decode(@response.body)
      
      assert_equal(@json.length, 2)
      person_mini_test(@json[0]['person'],@user2)
    end
    
    should "be able to view their contacts by searching" do
      path = "/api/contacts/search?term=Useroo"
      get path, {'access_token' => @access_token.code}
      assert_response :success, @response.body
      @json = ActiveSupport::JSON.decode(@response.body)

      person_basic_test(@json[0]['person'], @user2, @user)
    end
        
    should "be able to view a specific contact" do
      path = "/api/contacts/#{@user.person.id}"
      get path, {'access_token' => @access_token.code}
      assert_response :success, @response.body
      @json = ActiveSupport::JSON.decode(@response.body)

      keyword_test(@json['keywords'], @keyword)
      question_test(@json['questions'], @questions)
      person_full_test(@json['people'][0]['person'], @user, @user2)
      form_test(@json['people'][0]['form'], @questions, @answer_sheet)
    end
  
    should "be able to view a specific contact with a specific version" do
      path = "/api/v1/contacts/#{@user.person.id}"
      get path, {'access_token' => @access_token.code}
      assert_response :success, @response.body
      @json = ActiveSupport::JSON.decode(@response.body)
      
      keyword_test(@json['keywords'], @keyword)
      question_test(@json['questions'], @questions)
      person_full_test(@json['people'][0]['person'], @user, @user2)
      form_test(@json['people'][0]['form'], @questions, @answer_sheet)
    end
    
    should "be able to add a comment to a contact" do 
      path = "/api/followup_comments/"
      assert_equal(FollowupComment.all.count, 0)
      assert_equal(Rejoicable.all.count, 0)
      json = ActiveSupport::JSON.encode({:followup_comment => {:organization_id=> @user.person.primary_organization.id, :contact_id=>@user2.person.id, :commenter_id=>@user.person.id, :status=>"do_not_contact", :comment=>"Testing the comment system."}, :rejoicables => ["spiritual_conversation", "prayed_to_receive", "gospel_presentation"]})
      post path, {'access_token' => @access_token.code, 'json' => json }
      File.open('/users/Doulos/Desktop/testmytest.log', 'a') do |f2|
        f2.puts "TESTING: \n"
        f2.puts "#{@response.body}\n\n\n"
      end
      assert_equal(FollowupComment.all.count, 1)
      assert_equal(Rejoicable.all.count,3)
      assert_equal(FollowupComment.all.first.comment, "Testing the comment system.")
    end
    
    should "be able to get the followup comments" do
      #create a few test comments
      path = "/api/followup_comments/"
      json = ActiveSupport::JSON.encode({:followup_comment => {:organization_id=> @user.person.primary_organization.id, :contact_id=>@user2.person.id, :commenter_id=>@user.person.id, :status=>"do_not_contact", :comment=>"Testing the comment system."}, :rejoicables => ["spiritual_conversation", "prayed_to_receive", "gospel_presentation"]})
      post path, {'access_token' => @access_token.code, 'json' => json }
      post path, {'access_token' => @access_token.code, 'json' => json }
      path = "/api/followup_comments/#{@user2.person.id}"
      get path, {'access_token' => @access_token.code}
      @json = ActiveSupport::JSON.decode(@response.body)
      f1 = FollowupComment.first
      f2 = FollowupComment.last

      followup_comment_test(@json[0]['followup_comment'], f1, @user2.person, @user.person)
    end
    
    should "be able to create a contact assignment" do 
      path = "/api/contact_assignments/"
      ContactAssignment.destroy_all
      post path, {'access_token' => @access_token.code, :org_id => @user.person.primary_organization.id, :assign_to => @user2.person.id, :ids => @user2.person.id}
      assert_equal(@user2.person.contact_assignments.count, 1)
    end
    
    should "fail to create a contact assignment" do 
      path = "/api/contact_assignments/"
      ContactAssignment.destroy_all
      post path, {'access_token' => @access_token.code, :org_id => @user.person.primary_organization.id, :assign_to => "23423523a", :ids => @user2.person.id}
      @json = ActiveSupport::JSON.decode(@response.body)      
      assert_equal(@json['error']['code'], '27')
      
      ContactAssignment.destroy_all
      post path, {'access_token' => @access_token.code, :org_id => '234abc', :assign_to => "23423523", :ids => @user2.person.id}
      @json = ActiveSupport::JSON.decode(@response.body)      
      assert_equal(@json['error']['code'], '30')
    end
    
    should "be able to delete a contact assignment" do 
      ContactAssignment.destroy_all
      y = ContactAssignment.create(:organization_id => @user.person.primary_organization.id, :person_id => @user.person.id, :assigned_to_id => @user.person.id)
      assert_equal(@user.person.contact_assignments.count, 1)
      path = "/api/contact_assignments/#{@user.person.id}"
      delete path, {'access_token' => @access_token.code}
      assert_equal(@user.person.contact_assignments.count, 0)
    end
  end
  
  context "a user" do
    setup do
      @user = Factory.create(:user_with_auxs)
      @user2 = Factory.create(:user2_with_auxs)
      @user2.person.update_attributes(:firstName => "Test", :lastName => "Useroo")
      temp_org = @user.person.primary_organization.id
      @user2.person.organization_memberships.destroy_all
      @user.person.organization_memberships.destroy_all
      @user2.person.organization_memberships.create(:organization_id => temp_org, :person_id => @user2.person.id, :primary => 1, :role => "leader", :followup_status => "contacted")
      @user.person.organization_memberships.create(:organization_id => temp_org, :person_id => @user.person.id, :primary => 1, :role => "leader", :followup_status => "attempted_contact")
 
      ContactAssignment.create(:assigned_to_id => @user.person.id, :person_id => @user2.person.id, :organization_id => @user.person.organizations.first.id)
      ContactAssignment.create(:assigned_to_id => @user2.person.id, :person_id => @user.person.id, :organization_id => @user.person.organizations.first.id)
      @access_token = Factory.create(:access_token, :identity => @user.id)
      @access_token2 = Factory.create(:access_token, :identity => @user2.id, :code => "aoeuaocnpganoeuhnh234hnaeu")
    end
    
    should "be denied access to resources when they have the wrong scope" do
      path = "/api/contact_assignments/#{@user.person.id}"
      @access_token.update_attributes(:scope => "contacts userinfo followup_comments")
      delete path, {'access_token' => @access_token.code}
      @json = ActiveSupport::JSON.decode(@response.body)
      assert_equal(@json['error']['code'],"55")
      
      path = "/api/friends/#{@user.person.id}"
      @access_token.update_attributes(:scope => "contacts contact_assignment followup_comments")
      get path, {'access_token' => @access_token.code}
      @json = ActiveSupport::JSON.decode(@response.body)
      assert_equal(@json['error']['code'],"55")
      
      path = "/api/people/#{@user.person.id}"
      get path, {'access_token' => @access_token.code}
      @json = ActiveSupport::JSON.decode(@response.body)
      assert_equal(@json['error']['code'],"55")
    end
end
  
  ######################################
  ########## HELPER METHODS ############
  ######################################
  
  def followup_comment_test(json_comment, comment, contact, commenter)
    assert_equal(json_comment['comment']['id'], comment.id)
    assert_equal(json_comment['comment']['contact_id'], contact.id)
    assert_equal(json_comment['comment']['commenter']['id'], commenter.id)
    assert_equal(json_comment['comment']['commenter']['picture'], commenter.picture)
    assert_equal(json_comment['comment']['commenter']['name'], commenter.to_s)
    assert_equal(json_comment['comment']['comment'], comment.comment)
    assert_equal(json_comment['comment']['status'], comment.status)
    assert_equal(json_comment['comment']['organization_id'], contact.primary_organization.id)
    
    rejoicables_test(json_comment['rejoicables'], comment.rejoicables)
  end
  
  def rejoicables_test(json_rejoicables, rejoicables)
    json_rejoicables.each_with_index do |r,i|
      assert_equal(r['id'], rejoicables[i].id)
      assert_equal(r['what'], rejoicables[i].what)
    end
  end
  
  def friend_test(json_friend, friend)
    assert_equal(json_friend['name'],friend.name)
    assert_equal(json_friend['uid'], friend.uid)
    assert_equal(json_friend['provider'], friend.provider)
  end
  
  def form_test(json_form, questions, answer_sheet)
    json_form.each_with_index do |q,i|
      assert_equal(q['a'],questions[i].display_response(answer_sheet))
    end
  end
  
  def keyword_test(json_keywords,keywords)
    unless keywords.is_a? Array
      temp = keywords
      keywords = [temp]
    end
    json_keywords.each_with_index do |keyword,i|
      assert_equal(keyword['name'],'approved')
      assert_equal(keyword['keyword_id'],keywords[i].id)
      assert_equal(keyword['questions'], keywords[i].question_sheets.first.questions.collect(&:id))
    end
  end
  
  def question_test(json_questions,questions)
    json_questions.each_with_index do |question,i|
      assert_equal(question['id'],questions[i].id)
      assert_equal(question['kind'],questions[i].kind)
      assert_equal(question['label'],questions[i].label)
      assert_equal(question['style'],questions[i].style)  
      assert_equal(question['required'],questions[i].required)
    end
  end
  
  def person_mini_test(json_person,user)
    assert_equal(json_person['name'], user.person.to_s)
    assert_equal(json_person['id'], user.person.id)
  end
  
  def person_basic_test(json_person,user,user2)
    person_mini_test(json_person,user)
    assert_equal(json_person['picture'], user.person.picture)
    assert_equal(json_person['fb_id'], user.person.fb_uid.to_s)
    assert_equal(json_person['gender'], user.person.gender)
    assert_equal(json_person['status'], user.person.organization_memberships.first.followup_status)
    person_mini_test(json_person['assignment']['assigned_to_person'][0],user2)
    person_mini_test(json_person['assignment']['person_assigned_to'][0],user2)
    assert_equal(json_person['request_org_id'], user.person.primary_organization.id)
  end
  
  def person_full_test(json_person,user,user2)
    person_basic_test(json_person,user,user2)
    assert_equal(json_person['first_name'], user.person.firstName)
    assert_equal(json_person['last_name'], user.person.lastName)
    assert_equal(json_person['locale'], user.locale.nil? ? "" : user.locale)
    assert_equal(json_person['birthday'], user.person.birth_date.to_s)
    assert_equal(json_person['education'][0]['school']['name'], "Test High School")
    assert_equal(json_person['education'][1]['school']['name'], "Test University")
    assert_equal(json_person['education'][2]['school']['name'], "Test University 2")
    assert_equal(json_person['interests'][1]['name'], "Test Interest 2")
    assert_equal(json_person['organization_membership'][0]['org_id'], user.person.primary_organization.id)
    assert_equal(json_person['organization_membership'][0]['role'], user.person.organization_memberships.first.role)
    assert_equal(json_person['organization_membership'][0]['primary'].downcase, 'true')
  end
end

# File.open('/users/Doulos/Desktop/testmytest.log', 'a') do |f2|
#   f2.puts "should be able to view a specific contact\n"
#   f2.puts "#{JSON::pretty_generate(@json)}\n\n\n"
# end