module ApiTestHelper

######################################
########## API TEST SETUP ############
######################################

def setup_api_env
  Role.destroy_all
  Role.connection.execute("INSERT INTO `roles` (`id`, `organization_id`, `name`, `i18n`, `created_at`, `updated_at`)
  VALUES
  	(1, 0, 'Admin', 'admin', '2011-06-29 04:15:36', '2011-06-29 04:15:36'),
  	(2, 0, 'Contact', 'contact', '2011-06-29 04:15:36', '2011-06-29 04:15:36'),
  	(3, 0, 'Involved', 'involved', '2011-06-29 04:15:36', '2011-06-29 04:15:36'),
  	(4, 0, 'Leader', 'leader', '2011-06-29 04:15:36', '2011-06-29 04:15:36'),
  	(5, 0, 'Alumni', 'alumni', '2011-06-29 04:15:36', '2011-06-29 04:15:36');
  ")
  @user = Factory.create(:user_with_auxs)
  @user2 = Factory.create(:user2_with_auxs)
  @user3 = Factory.create(:user3_with_auxs)
  
  @user2.person.update_attributes(firstName: "Test", lastName: "Useroo")
  @user3.person.update_attributes(firstName: "Another Test", lastName: "Usereeeee")
  
  #now let's make sure they all have the same organization
  @temp_org = @user.person.primary_organization
  
  #destroy old memberships
  @user.person.organization_memberships.destroy_all
  @user2.person.organization_memberships.destroy_all
  @user3.person.organization_memberships.destroy_all
  
  #destroy old roles
  @user.person.organizational_roles.destroy_all
  @user2.person.organizational_roles.destroy_all
  @user3.person.organizational_roles.destroy_all
  
  #create new roles all pointed towards @temp_org
  @user.person.organizational_roles.create(organization_id: @temp_org.id, person_id: @user.person.id, role_id: Role.contact.id, followup_status: "attempted_contact")
  @user2.person.organizational_roles.create(organization_id: @temp_org.id, person_id: @user2.person.id, role_id: Role.contact.id, followup_status: "contacted")
  @user3.person.organizational_roles.create(organization_id: @temp_org.id, person_id: @user3.person.id, role_id: Role.admin.id, followup_status: "uncontacted")  

  #create new memberships all pointed towards @temp_org
  @user.person.organization_memberships.create(organization_id: @temp_org.id, person_id: @user.person.id, primary: 1)
  @user2.person.organization_memberships.create(organization_id: @temp_org.id, person_id: @user2.person.id, primary: 1)
  @user3.person.organization_memberships.create(organization_id: @temp_org.id, person_id: @user3.person.id, primary: 1)
    
  #create contact assignments
  Factory.create(:contact_assignment, assigned_to_id: @user.person.id, person_id: @user2.person.id, organization_id: @temp_org.id)
  Factory.create(:contact_assignment, assigned_to_id: @user2.person.id, person_id: @user.person.id, organization_id: @temp_org.id)
  
  File.open('/users/Doulos/Desktop/testmytest.log', 'a') do |f2|
    f2.puts "restart\n"
    f2.puts "#{@user.person.inspect}\n\n"
    f2.puts "#{@user2.person.inspect}\n\n"
    f2.puts "#{OrganizationalRole.all.inspect}\n\n"
    f2.puts "#{@user.person.organizational_roles.inspect}\n"
    f2.puts "#{@user2.person.organizational_roles.inspect}\n"
    f2.puts "#{@user.person.organization_memberships.inspect}\n"
    f2.puts "#{@user2.person.organization_memberships.inspect}\n"
    f2.puts "#{@user.person.contact_assignments.inspect}\n"
    f2.puts "#{@user2.person.contact_assignments.inspect}\n"
  end

  @access_token = Factory.create(:access_token, identity: @user.id)
  @access_token2 = Factory.create(:access_token, identity: @user2.id, code: "abcdefgh")
  @access_token3 = Factory.create(:access_token, identity: @user3.id, code: "abcdefghijklmnop")
  
  #setup question sheets, questions, and an answer sheet for user1 and user2
  @keyword = Factory(:approved_keyword, organization: @temp_org)
  @firstNameQ = Factory(:element)
  @keyword.question_page.elements << @firstNameQ  
  @questions = @keyword.question_sheet.questions
  @answer_sheet = Factory(:answer_sheet, question_sheet: @keyword.question_sheet, person: @user.person)
  @answer_sheet2 = Factory(:answer_sheet, question_sheet: @keyword.question_sheet, person: @user2.person)
  @answer_to_choice = Factory(:answer_1, answer_sheet: @answer_sheet, question: @questions.first)
  @answer_to_choice2 = Factory(:answer_1, answer_sheet: @answer_sheet2, question: @questions.first)
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
    assert_equal(json_person['status'], user.person.organizational_roles.first.followup_status)
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
    assert_equal(json_person['organizational_roles'][0]['role'], user.person.organizational_roles.first.role.i18n)
    assert_equal(json_person['organization_membership'][0]['primary'].downcase, 'true')
  end
end