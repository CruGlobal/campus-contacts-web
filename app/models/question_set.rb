# QuestionSet
# represents a group of elements, with their answers
class QuestionSet
  
  attr_reader :elements
  
  # associate answers from database with a set of elements
  def initialize(elements, answer_sheet)
    @elements = elements
    @answer_sheet = answer_sheet
  
    @questions = elements.select { |e| e.question? }
  
    # answers = @answer_sheet.answers_by_question
  
    @questions.each do |question|
      question.answers = question.responses(answer_sheet) #answers[question.id]
    end    
    @questions
  end
  
  # update with responses from form
  def post(params, answer_sheet)
    questions_indexed = @questions.index_by {|q| q.id}
    
    # loop over form values
    params ||= {}
    params.each do |question_id, response|
      if response.to_s.strip.present? # Don't save blanks
        next if questions_indexed[question_id.to_i].nil? # the rare case where a question was removed after the app was opened.
        # update each question with the posted response
        questions_indexed[question_id.to_i].set_response(posted_values(response), answer_sheet)
      else
        answer = Answer.find_by_answer_sheet_id_and_question_id(answer_sheet.id,question_id)
        if answer.present?
          answer.destroy
        end
      end
    end
  end
  
  def any_questions?
    @questions.length > 0
  end
  
  def save
    AnswerSheet.transaction do
      @questions.each do |question|
        question.save_response(@answer_sheet, question)
        answer = @answer_sheet.answers.find_by_question_id(question.id).value
        qrules = SurveyElement.find_by_element_id(question.id).question_rules
        qrules.each do |qrule|
          triggers = qrule.trigger_keywords.gsub(" ","").split(",")
          code = qrule.rule.rule_code
          case code
          when "AUTONOTIFY"
            valid = false
            Rails.logger.info ""
            Rails.logger.info ""
            Rails.logger.info "### Checking AUTONOTIFY"
            Rails.logger.info "### Recipients: #{qrule.extra_parameters['leaders']}"
            Rails.logger.info "### Triggers: #{triggers.inspect}"
            Rails.logger.info "### Answer: \"#{answer}\""
            triggers.each do |t|
              if answer.downcase.index(t.downcase) != nil
                Rails.logger.info "### Trigger \"#{t}\" detected!"
                valid = true
              end
            end
            if valid
              Rails.logger.info "### Applying AUTONOTIFY Rule"
            else
              Rails.logger.info "### No triggers fired!"
            end
            Rails.logger.info ""
            Rails.logger.info ""
          end
        end
      end
    end
  end
  
  
  private
  
  # convert posted response to a question into Array of values
  def posted_values(param)
  
    if param.kind_of?(Hash) && param.has_key?('year') && param.has_key?('month')
      year = param['year']
      month = param['month']
      if month.blank? or year.blank?
        values = ''
      else
        values = [Date.new(year.to_i, month.to_i, 1).strftime('%m/%d/%Y')]  # for mm/yy drop downs
      end
    elsif param.kind_of?(Hash)
      # from Hash with multiple answers per question
      values = param.values.map {|v| CGI.unescape(v)}.select {|v| v.to_s.strip.present?}
    elsif param.kind_of?(String)
      values = param.strip.present? ? [CGI.unescape(param)] : []
    end
  
    # Hash may contain empty string to force post for no checkboxes
#    values = values.reject {|r| r == ''}
  end
  
end
