FactoryGirl.define do
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
end