FactoryGirl.define do
  sequence(:count) {|n| n}

  def attachment(name, path, content_type = nil)
    path_with_rails_root = "#{RAILS_ROOT}/#{path}"
    uploaded_file = if content_type ActionController::TestUploadedFile.new(path_with_rails_root, content_type)
                    else ActionController::TestUploadedFile.new(path_with_rails_root)
                    end

    add_attribute name, uploaded_file
  end
  
=begin
  factory :csv_file do
    include ActionDispatch::TestProcess 
    csv_file fixture_file_upload('/files/sample_contacts.csv', 'application/csv')
  end
=end

  factory :group do
    name 'foo'
    location 'here'
    meets 'sporadically'
    association :organization
  end
  
  factory :sms_session do
    phone_number '15555555555'
    # association :person
    # association :sms_keyword
  end
  
  factory :received_sms do
    phone_number '15555555555'
    carrier      'sprint'
    shortcode    '69940'
    message      'test'
    country      'US'
  end
  
  factory :sms_carrier do
    moonshado_name 'fake'
  end
  
  factory :sms_carrier_sprint, parent: :sms_carrier do
    name 'Sprint'
    moonshado_name 'sprint'
    email 'messaging.sprintpcs.com'
  end
  
  factory :sms_keyword do 
    keyword {"test#{Factory.next(:count)}"}
    association :organization
    explanation "haoeu"
    state "requested"
    initial_response "Hi there!"
    association :user
    association :survey
  end
  
  factory :approved_keyword, parent: :sms_keyword do
    keyword 'approved'
    association :organization
    explanation "haoeu"
    state "active"
    initial_response "Hi there!"
    association :user
    after_create do |x| 
      survey = Factory(:survey, organization: x.organization)
      x.update_attribute(:survey_id, survey.id)
      element = Factory(:choice_field, label: 'foobar')
      Factory(:survey_element, survey: survey, element: element, position: 1, archived: true)
      element = Factory(:choice_field)
      Factory(:survey_element, survey: survey, element: element, position: 2)
    end
  end
  
  factory :survey do
    title {"Test survey #{Factory.next(:count)}"}
    association :organization
    post_survey_message "bye!"
    login_option 0
  end
  
  factory :person do 
    firstName 'John'
    lastName 'Doe'
    gender '1'
    fb_uid {"690860831#{Factory.next(:count)}"}
    birth_date {DateTime.strptime('12/18/1989', '%m/%d/%Y')}
  end
  
  factory :person_without_name, parent: :person do
    firstName ''
    lastName ''
  end
  
  factory :user do
    email {"test#{Factory.next(:count)}@example.com"}
    password 'asdfasdf'
  end
  
  factory :authentication do
    provider "facebook"
    uid {"690860831#{Factory.next(:count)}"}
    token "164949660195249|bd3f24d52b4baf9412141538.1-690860831|w79R36CalrEAY-9e9kp8fDWJ69A"
  end
  
  factory :friend do
    
    name "Test Friend #{Factory.next(:count)}"
    uid {Factory.next(:count)}
    provider "facebook"
  end
  
  factory :organization do
    name {"Organization #{Factory.next(:count)}"}
    terminology 'Organization'
    show_sub_orgs true
    status 'active'
  end
  
  factory :location do 
    name "Orlando, FL"
    location_id 1
    provider "facebook"
  end
  
  factory :education_history_highschool, class: EducationHistory do
    school_name "Test High School"
    school_id "3"
    school_type "High School"
    year_id "4"
    year_name "2008"
    provider "facebook"
  end  
  
  factory :education_history_college, class: EducationHistory do
    school_name "Test University"
    school_id "1"
    school_type "College"
    year_id "2"
    year_name "2012"
    provider "facebook"
    concentration_id1 "12"
    concentration_name1 "Test Major 1"
    concentration_id2 "42"
    concentration_name2 "Test Major 2"
    concentration_id3 "84"
    concentration_name3 "Test Major 3"
  end
  
  factory :education_history_gradschool, class: EducationHistory do
    school_name "Test University 2"
    school_id "2"
    school_type "College"
    year_id "4"
    year_name "2014"
    provider "facebook"
    concentration_id1 "13"
    concentration_name1 "Test Major 4"
    concentration_id2 "43"
    concentration_name2 "Test Major 5"
    concentration_id3 "86"
    concentration_name3 "Test Major 6"
    degree_id "1"
    degree_name "Masters"
  end
  
  factory :interest, class: Interest do
    interest_id "#{Factory.next(:count)}"
    name "Test Interest #{Factory.next(:count)}"
    provider "facebook"
    category "Test Category"
  end
    
  factory :access_token, class: Rack::OAuth2::Server::AccessToken do
    code "9d68af577f8a4c9076752c9699d2ac2ace64f9dcb407897f754439096cedbfca"
    scope "userinfo contacts followup_comments contact_assignment roles organization_info"
  end
  
  factory :user_with_authentication, parent: :user do
    after_create { |a| Factory(:authentication, user: a)}
  end
  
  factory :person_with_facebook_data, parent: :person do
    after_create do |f| 
      3.times {Factory(:friend, person: f)}
      Factory(:education_history_highschool, person: f)
      Factory(:education_history_college, person: f)
      Factory(:education_history_gradschool, person: f)
      2.times {Factory(:interest, person: f)}
      Factory(:location, person: f)
    end
  end
  
   factory :person_with_things, parent: :person do 
     after_create do |f| 
       3.times {Factory(:friend, person: f)}
       Factory(:education_history_highschool, person: f)
       Factory(:education_history_college, person: f)
       Factory(:education_history_gradschool, person: f)
       Factory(:interest, person: f)
       Factory(:interest, person: f)
       Factory(:location, person: f)
       org = Factory(:organization)
       org.add_admin(f)
    end
  end
  
  factory :organizational_role do 
    association :organization
    association :person
    association :role
    followup_status "attempted_contact"
  end
  
  factory :organization_membership do 
    association :organization
    association :person
  end
  
  factory :followup_comment do
    association :contact
    association :organization
    association :commenter
  end
  
  factory :contact_assignment do 
    association :organization
    association :assigned_to
    association :person
  end
  
  factory :user_with_auxs, parent: :user do
    after_create do |a| 
      Factory(:person_with_things, user: a)
      Factory(:authentication, user: a)
    end
  end
  
  factory :user_no_org_with_facebook, parent: :user do
    after_create do |a|
      Factory(:person_with_facebook_data, user: a)
    end
  end
  
  factory :user_no_org, parent: :user do
    after_create do |a| 
      Factory(:person, user: a)
      Factory(:authentication, user: a)
    end
  end
  
  factory :element do
    kind          'TextField'
    label         'First Name'
    style         'short'
    object_name   'person'
    attribute_name 'firstName'
    required      false
  end


  
  factory :advanced_element, parent: :element do
    kind             'TextField'
    label            'Sample question'
    style            'short'
  end
  
  factory :question_leader do
    association :element
    association :person
  end
  
  factory :question do
    association :element
  end
  
  factory :choice_field, parent: :element do
    kind          'ChoiceField'
    label         'Which of the following are you interested in? #{Factory.next(:count)}'
    style         'checkbox'
    content       "Prayer Group\nJesus"
    object_name ''
    attribute_name ''
  end
  
  factory :firstName_element, parent: :element do
    kind          'TextField'
    label         'First name?'
    style 'short'
    object_name 'person'
    attribute_name 'firstName'
  end
  
    factory :lastName_element, parent: :element do
    kind          'TextField'
    label         'Last name?'
    style 'short'
    object_name 'person'
    attribute_name 'lastName'
  end

  factory :email_element, parent: :element do
    kind          'TextField'
    label         'What is your email?'
    style         'short'
    object_name   'person'
    attribute_name 'email'
    required      false
  end
  
  factory :phone_element, parent: :element do
    kind          'TextField'
    label         'What is your phone number?'
    style         'short'
    object_name   'person'
    attribute_name 'phone_number'
    required      false
  end
  
  factory :survey_element do
    association   :survey
    association   :element
    position        1
  end
  
  factory :answer do
    association :answer_sheet
    association :choice_field
  end
  
  factory :answer_1, class: :answer do
    value "Jesus"
    short_value "Jesus"
    association :answer_sheet
  end
  
  factory :answer_sheet do
    association :survey
    association :person
  end

  factory :member_role do
    association :organization
    name        'member'
    i18n        'member'
  end

  factory :role do
    association :organization
    name        {"role #{Factory.next(:count)}"}
  end
  
  factory :infobase_user, class: Ccc::InfobaseUser do
    association :user
    type        'InfobaseUser'
  end
  
  factory :super_admin do
    association :user
  end
end
