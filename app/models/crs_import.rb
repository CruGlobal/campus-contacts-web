class CrsImport

  def initialize(org, user)
    @org = org
    @conference = org.conference
    @user = user
  end

  def import
    email_address = user.person.try(:email)
    if @conference
      begin
        questions = {}
        Organization.transaction do
          # create a missionhub question for each crs question
          Ccc::Crs2Question.where("conference_id = ? OR common = 1", @conference.id).each do |crs_question|
            case crs_question.type
            when 'integer', 'shortText', 'mediumText', 'singleCharacter', 'paragraph', 'number'
              kind = TextField
              style = 'short'
            when 'dropdown'
              kind = ChoiceField
              style = 'drop-down'
            when 'radio', 'checkbox'
              kind = ChoiceField
              style = crs_question.type
            when 'date'
              kind = DateField
              style = 'date_field'
            end

            unless question = Element.where(crs_question_id: crs_question.id).first
              question = kind.new(crs_question_id: crs_question.id)
            end
            question.attributes = {kind: kind, style: style, label: crs_question.name}

            # add options if it's a multiple choice question
            question.content = crs_question.question_options.collect(&:value).join("\n")

            question.save!
            questions[crs_question.id] = question
          end

          @conference.registrant_types.each do |registrant_type|
            # create role/label
            role = @org.roles.where(name: registrant_type.name).first_or_create

            # create survey
            survey = @org.surveys.where(crs_registrant_type_id: registrant_type.id).
                       first_or_create(name: registrant_type.name)

            # add questions to survey
            registrant_type.custom_questions_items.where("question_id is not null").each do |cqi|
              survey.survey_elements.where(element_id: questions[cqi.question_id].id).first_or_create
            end

            # Import registrants
            registration_type.registrants.each do |registrant|
              # Find or create missionhub person
              person = Person.where(crs_profile_id: registrant.profile_id).first
              unless person
                # TODO: try to match an existing person based on username or email address

                # TODO: if we couldn't find them that way, phone number and exact name match is also good

                # TODO: if we still couldn't find someone, we create a new record

              end
              # TODO: import latest address/email/phone

              # Make this person a contact in this org
              @org.add_contact(person)
              # add them to the role corresponding to their registrant type
              @org.add_role(person, role.id)

              # Each registrant gets an answer_sheet
              answer_sheet = AnswerSheet.where(person_id: person.id, survey_id: survey.id).first_or_create

              # Copy over answers
              registrant.answers.each do |a|
                value = a.value_boolean || a.value_date || a.value_double || a.value_int || a.value_string || a.value_text
                question = questions[a.custom_questions_item.question_id]
                # If this question is multiple choice, we need to capture all answers
                if question.is_a?(ChoiceField)
                  Answer.where(answer_sheet_id: answer_sheet.id, question_id: question.id, value: value).first_or_create
                else
                  # If it's not, we can just look for one answer and possibly update it
                  a = Answer.where(answer_sheet_id: answer_sheet.id, question_id: question.id).first_or_initialize
                  a.value = value
                  a.save
                end
              end

            end
          end

          CrsImportMailer.completed(self, email_address).deliver if email_address
        end
      rescue
        CrsImportMailer.failed(self, email_address).deliver if email_address
      end
    else
      CrsImportMailer.failed(self, email_address).deliver if email_address
    end
  end
end
