class Ccc::SpPage < ActiveRecord::Base
  has_many :sp_page_elements, class_name: 'Ccc::SpPageElement'
  belongs_to :sp_question_sheets, class_name: 'Ccc::SpQuestionSheet', foreign_key: :question_sheet_id
end
