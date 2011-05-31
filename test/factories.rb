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
  #     #p.after_create { |i| Factory(:interest, :person => i)}
  #     #p.after_create { |e| Factory(:education_history, :person => e)}
  #     #p.after_create { |l| Factory(:location, :person => l)}
  end
  
  Factory.define :user_with_auxs, :parent => :user do |u|
    u.after_create { |a| Factory(:person_with_things, :user => a)}
    u.after_create { |a| Factory(:authentication, :user => a)}
  end
  
  
end

