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
  
  factory :person do
    firstName 'John'
    lastName 'Doe'
  end
  
  factory :user do
    email 'test@example.com'
    password 'asdfasdf'
    person
  end
  
  factory :authentication do
    provider "facebook"
    uid "690860831"
    token "164949660195249|bd3f24d52b4baf9412141538.1-690860831|w79R36CalrEAY-9e9kp8fDWJ69A"
  end
end