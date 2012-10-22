class Ccc::PrSummaryForm < AnswerSheet
  establish_connection :uscm

  belongs_to :review, class_name: 'Ccc::PrReview'
  #belongs_to :person
  self.table_name = "pr_summary_forms"

  def question_sheets
    [ review.question_sheet.summary_form ]
  end

  def can_view?(p)
    return p.admin? || p == review.initiator
  end

  def submit!
  end

  def collat_title
    review.initiator
  end

end
