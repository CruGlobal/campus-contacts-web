FactoryGirl.define do
  sequence(:count) {|n| n}
  
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
  
  factory :sms_carrier_sprint, :parent => :sms_carrier do
    name 'Sprint'
    moonshado_name 'sprint'
    email 'messaging.sprintpcs.com'
  end
  
  factory :sms_keyword do 
    keyword 'test'
    association :organization
    explanation "haoeu"
    state "requested"
    initial_response "Hi there!"
    post_survey_message "bye!"
    association :user
  end
  
  factory :approved_keyword, :parent => :sms_keyword do
    keyword 'approved'
    association :organization
    explanation "haoeu"
    state "active"
    initial_response "Hi there!"
    post_survey_message "bye!"
    association :user
    after_create do |x| 
      question_sheet = Factory(:question_sheet, :questionnable => x)
      page = Factory(:page, :question_sheet => question_sheet)
      element = Factory(:choice_field)
      Factory(:page_element, :page => page, :element => element)
    end
  end
  
  factory :question_sheet do
    label {"Test Sheet #{Factory.create(:count)}"}
    archived 0
  end
  
  factory :person do 
    firstName 'John'
    lastName 'Doe'
    gender '1'
    birth_date {DateTime.strptime('12/18/1989', '%m/%d/%Y')}
  end
  
  factory :user do
    email 'test@exampl.com'
    password 'asdfasdf'
  end
  
  factory :authentication do
    provider "facebook"
    uid "690860831"
    token "164949660195249|bd3f24d52b4baf9412141538.1-690860831|w79R36CalrEAY-9e9kp8fDWJ69A"
  end
  
  factory :friend do
    name "Test Friend"
    uid "1234567890"
    provider "facebook"
  end
  
  factory :organization do
    name {"Organization #{Factory.create(:count)}"}
    terminology 'Organization'
  end
  
  factory :location do 
    name "Orlando, FL"
    location_id 1
    provider "facebook"
  end
  
  factory :education_history_highschool, :class => EducationHistory do
    school_name "Test High School"
    school_id "3"
    school_type "High School"
    year_id "4"
    year_name "2008"
    provider "facebook"
  end  
  
  factory :education_history_college, :class => EducationHistory do
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
  
  factory :education_history_gradschool, :class => EducationHistory do
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
  
  factory :interest, :class => Interest do
    interest_id "1"
    name "Test Interest 1"
    provider "facebook"
    category "Test Category"
  end
  
  factory :interest_2, :class => Interest do
    interest_id "2"
    name "Test Interest 2"
    provider "facebook"
    category "Test Category"
  end
    
  factory :access_token, :class => Rack::OAuth2::Server::AccessToken do
    code "9d68af577f8a4c9076752c9699d2ac2ace64f9dcb407897f754439096cedbfca"
    scope "userinfo"
  end
  
  factory :user_with_authentication, :parent => :user do
    after_create { |a| Factory(:authentication, :user => a)}
  end
  
   factory :person_with_things, :parent => :person do
     after_create do |f| 
       Factory(:friend, :person => f)
       Factory(:friend, :person => f)
       Factory(:friend, :person => f)
       Factory(:education_history_highschool, :person => f)
       Factory(:education_history_college, :person => f)
       Factory(:education_history_gradschool, :person => f)
       Factory(:interest, :person => f)
       Factory(:interest_2, :person => f)
       Factory(:location, :person => f)
    end
  end
  
  factory :user_with_auxs, :parent => :user do
    after_create do |a| 
      Factory(:person_with_things, :user => a)
      Factory(:authentication, :user => a)
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
  
  factory :choice_field, :parent => :element do
    kind          'ChoiceField'
    label         'Which of the following are you interested in?'
    style         'checkbox'
    content       "Prayer Group\nJesus"
  end
  
  factory :page do
    association   :question_sheet
    label         'Welcome!'
    number        1
  end
  
  factory :page_element do
    association   :page
    association   :element
    position        1
  end
end

