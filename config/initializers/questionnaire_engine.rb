#require  Rails.root.join('lib', 'questionnaire_engine', 'init')

module Questionnaire
  # prefix for database tables
  mattr_accessor :table_name_prefix
  self.table_name_prefix = 'mh_'
  
  mattr_accessor :answer_sheet_class
  self.answer_sheet_class = 'AnswerSheet'
  
  mattr_accessor :from_email
  self.from_email = 'MissionHub <help@campuscrusadeforchrist.com>'
  
end
