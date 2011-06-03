FactoryGirl.define do
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
  
  Factory.define :sms_keyword do |s|
    s.keyword 'test'
    s.organization_id 1
    s.explanation "haoeu"
    s.state "requested"
    s.initial_response "Hi there!"
    s.post_survey_message "bye!"
    s.user_id 1
  end
  
  Factory.define :question_sheet do |y|
    y.label "Test Sheet"
    y.archived 0
    y.questionnable_type "SmsKeyword"
  end
  
  Factory.define :sms_keyword_with_question_sheet, :parent => :sms_keyword do |q|
    #q.after_create { |x| Factory(:question_sheet, :sms_keyword => x)}
  end
  
  Factory.define :person do |p|
    p.firstName 'John'
    p.lastName 'Doe'
    p.gender '1'
    p.birth_date DateTime.strptime('12/18/1989', '%m/%d/%Y')
  end
  
  Factory.define :user do |u|
    u.email 'test@example.com'
    u.password 'asdfasdf'
  end
  
  Factory.define :authentication do |a|
    a.provider "facebook"
    a.uid "690860831"
    a.token "164949660195249|bd3f24d52b4baf9412141538.1-690860831|w79R36CalrEAY-9e9kp8fDWJ69A"
  end
  
  Factory.define :friend do |f|
    f.name "Test Friend"
    f.uid "1234567890"
    f.provider "facebook"
  end
  
  Factory.define :location do |l|
    l.name "Orlando, FL"
    l.location_id 1
    l.provider "facebook"
  end
  
  Factory.define :education_history_highschool, :class => EducationHistory do |e|
    e.school_name "Test High School"
    e.school_id "3"
    e.school_type "High School"
    e.year_id "4"
    e.year_name "2008"
    e.provider "facebook"
  end  
  
  Factory.define :education_history_college, :class => EducationHistory do |e|
    e.school_name "Test University"
    e.school_id "1"
    e.school_type "College"
    e.year_id "2"
    e.year_name "2012"
    e.provider "facebook"
    e.concentration_id1 "12"
    e.concentration_name1 "Test Major 1"
    e.concentration_id2 "42"
    e.concentration_name2 "Test Major 2"
    e.concentration_id3 "84"
    e.concentration_name3 "Test Major 3"
  end
  
  Factory.define :education_history_gradschool, :class => EducationHistory do |e|
    e.school_name "Test University 2"
    e.school_id "2"
    e.school_type "College"
    e.year_id "4"
    e.year_name "2014"
    e.provider "facebook"
    e.concentration_id1 "13"
    e.concentration_name1 "Test Major 4"
    e.concentration_id2 "43"
    e.concentration_name2 "Test Major 5"
    e.concentration_id3 "86"
    e.concentration_name3 "Test Major 6"
    e.degree_id "1"
    e.degree_name "Masters"
  end
  
  Factory.define :interest, :class => Interest do |i|
    i.interest_id "1"
    i.name "Test Interest 1"
    i.provider "facebook"
    i.category "Test Category"
  end
  
  Factory.define :interest_2, :class => Interest do |i|
    i.interest_id "2"
    i.name "Test Interest 2"
    i.provider "facebook"
    i.category "Test Category"
  end
    
  Factory.define :access_token, :class => Rack::OAuth2::Server::AccessToken do |t|
    t.code "9d68af577f8a4c9076752c9699d2ac2ace64f9dcb407897f754439096cedbfca"
    t.scope "userinfo"
  end
  
  Factory.define :user_with_authentication, :parent => :user do |u|
    u.after_create { |a| Factory(:authentication, :user => a)}
  end
  
   Factory.define :person_with_things, :parent => :person do |p|
     p.after_create { |f| Factory(:friend, :person => f)}
     p.after_create { |f| Factory(:friend, :person => f)}
     p.after_create { |f| Factory(:friend, :person => f)}
     p.after_create { |f| Factory(:education_history_highschool, :person => f)}
     p.after_create { |f| Factory(:education_history_college, :person => f)}
     p.after_create { |f| Factory(:education_history_gradschool, :person => f)}
     p.after_create { |f| Factory(:interest, :person => f)}
     p.after_create { |f| Factory(:interest_2, :person => f)}
     p.after_create { |f| Factory(:location, :person => f)}
  end
  
  Factory.define :user_with_auxs, :parent => :user do |u|
    u.after_create { |a| Factory(:person_with_things, :user => a)}
    u.after_create { |a| Factory(:authentication, :user => a)}
  end
  
  
end

