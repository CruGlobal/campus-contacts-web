require 'answer_sheet'
class Ccc::PrPersonalForm < AnswerSheet
  self.table_name = "pr_personal_forms"

  belongs_to :person
  belongs_to :question_sheet

  def question_sheets
    [ question_sheet ]
  end

  def submit!
  end
end
