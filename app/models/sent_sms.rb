class SentSms < ActiveRecord::Base
  @queue = :general
  serialize :reports
  
end
