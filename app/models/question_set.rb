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
        answer = @answer_sheet.answers.find_by_question_id(question.id)
        question_rules = SurveyElement.find_by_element_id(question.id).question_rules

        if answer.present? && question_rules.present?
          question_rules.each do |question_rule|
            triggers = question_rule.trigger_keywords.gsub(' ','').split(',')
            code = question_rule.rule.rule_code

            case code
            when 'AUTONOTIFY'
              keyword_found = ''

              # Check if triggers exists
              triggers.each do |t|
                keyword_found = t unless answer.value.downcase.index(t.downcase) == nil
              end

              # Do the process
              unless keyword_found.blank?
                leaders = Person.find(question_rule.extra_parameters['leaders'])
                recipients = leaders.collect{|p| "#{p.name} <#{p.email}>"}.join(", ")
                PeopleMailer.enqueue.notify_on_survey_answer(recipients, question_rule.id, keyword_found, answer.id)
              end

            when 'AUTOASSIGN'
              keyword_found = ''

              # Check if triggers exists
              triggers.each do |t|
                keyword_found = t unless answer.value.downcase.index(t.downcase) == nil
              end

              # Do the process
              unless keyword_found.blank?
                organization = @answer_sheet.survey.organization
                type = question_rule.extra_parameters['type'].downcase
                assign_to_id = question_rule.extra_parameters['id']
                person =  @answer_sheet.person

                if type.present? && assign_to_id.present?
                  case type
                  when 'leader'
                    Rails.logger.info "Running Leader Process"
                    if Person.exists?(assign_to_id)
                      @assign_to = Person.find(assign_to_id)
                      ContactAssignment.where(
                        person_id: person.id,
                        organization_id: organization.id).destroy_all
                      ContactAssignment.create(
                        person_id: person.id,
                        organization_id: organization.id,
                        assigned_to_id: @assign_to.id)
                    end
                  when 'ministry'
                    if Organization.exists?(assign_to_id)
                      @assign_to = Organization.find(assign_to_id)
                      @assign_to.add_contact(person)
                    end
                  when 'group'
                    if Group.exists?(assign_to_id)
                      @assign_to = Group.find(assign_to_id)
                      group_membership = @assign_to.group_memberships.find_or_initialize_by_person_id(person.id)
                      group_membership.permission = 'member'
                      group_membership.save
                    end
                  when 'label'
                    if Permission.exists?(assign_to_id)

                      new_permissions = [assign_to_id]
                      old_permissions = person.organizational_permissions.where(organization_id: organization.id).collect { |permission| permission.permission_id }
                      permissions_to_add = new_permissions - old_permissions
                      permissions_to_remove = old_permissions - new_permissions

                      person.organizational_permissions.where(organization_id: organization.id, permission_id: permissions_to_remove).destroy_all

                      all_permissions = permissions_to_add | (new_permissions & old_permissions)
                      all_permissions.sort!.each do |permission_id|
                        OrganizationalPermission.find_or_create_by_person_id(
                          person_id: person.id,
                          permission_id: permission_id,
                          organization_id: organization.id) if permissions_to_add.include?(permission_id)
                      end
                    end
                  end
                end
              end
            end
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
