module Questionnaire
  # prefix for database tables
  mattr_accessor :table_name_prefix
  self.table_name_prefix = 'ma_'
  
  mattr_accessor :answer_sheet_class
  self.answer_sheet_class = 'AnswerSheet'
  
  mattr_accessor :from_email
  self.from_email = 'Mission Accelerator <help@campuscrusadeforchrist.com>'
  
end