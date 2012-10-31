class CrsImport

  def initialize(org, user)
    @org = org
    @conference = org.conference
    @user = user
  end

  def import
    email_address = @user.person.try(:email)
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

            if question = Element.where(crs_question_id: crs_question.id).first
              # Make sure it's the same kind of question
              unless question.is_a?(kind)
                Question.connection.update("update elements set kind = #{kind} where id = #{question.id}")
                question = kind.where(crs_question_id: crs_question.id).first
              end
            else
              question = kind.new(crs_question_id: crs_question.id)
            end

            question.attributes = {style: style, label: crs_question.name}

            # add options if it's a multiple choice question
            question.content = crs_question.question_options.collect(&:value).join("\n")

            question.save!
            questions[crs_question.id] = question
          end

          @conference.registrant_types.each do |registrant_type|
            # create role/label
            role = Role.where(organization_id: @org.id, name: registrant_type.name).first_or_create!

            # create survey
            survey = @org.surveys.where(crs_registrant_type_id: registrant_type.id).
                       first_or_initialize(title: registrant_type.name)
            survey.save(validate: false)

            # add questions to survey
            registrant_type.custom_questions_items.where("question_id is not null").each do |cqi|
              survey.survey_elements.where(element_id: questions[cqi.question_id].id).first_or_create!
            end

            # Import registrants
            registrant_type.registrants.where(status: 'Complete').each do |registrant|
              # Find or create missionhub person
              person = Person.where(crs_profile_id: registrant.profile_id).first

              # Get the ministry_person or the crs2_person
              profile = registrant.profile
              crs2_person = profile.ministry_person || profile.crs2_person

              unless person
                # try to match an existing person based on username or email address
                crs2_person.all_email_addresses.each do |email|
                  person = Person.find_existing_person_by_email(email)
                  break if person
                end

                # if we couldn't find them that way, phone number and exact name match is also good
                unless person
                  crs2_person.all_phone_numbers.each do |phone_number|
                    person = Person.find_existing_person_by_name_and_phone(first_name: crs2_person.preferred_or_first,
                                                                           last_name: crs2_person.last_name,
                                                                           number: phone_number)

                    break if person
                  end
                end

                # if we still couldn't find someone, we create a new record
                person = Person.new(first_name: crs2_person.preferred_or_first,
                                        last_name: crs2_person.last_name,
                                        middle_name: crs2_person.middle_name,
                                        gender: crs2_person.gender_as_int,
                                        major: crs2_person.major,
                                        campus: crs2_person.campus,
                                        greek_affiliation: crs2_person.greek_affiliation,
                                        birth_date: crs2_person.birth_date,
                                        date_became_christian: crs2_person.date_became_christian,
                                        graduation_date: crs2_person.graduation_date,
                                        year_in_school: crs2_person.year_in_school,
                                        minor: crs2_person.minor)
              end

              # Link to crs profile
              person.crs_profile_id = registrant.profile_id
              person.save!

              # import latest address/email/phone
              crs2_person.all_email_addresses.each do |email|
                begin
                  person.email = email
                  person.save!
                rescue ActiveRecord::RecordInvalid
                  # find the other person, if name also matches, merge the two
                  other_person = Person.find_existing_person_by_email(email)
                  if other_person && other_person.first_name.downcase == person.first_name.downcase &&
                     other_person.last_name.downcase == person.last_name.downcase
                    person = person.merge(other_person)
                  end
                end
              end

              crs2_person.all_phone_numbers.each do |number|
                person.phone_number = number
              end

              # Make this person a contact in this org
              @org.add_contact(person)
              # add them to the role corresponding to their registrant type
              @org.add_role_to_person(person, role.id)

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
                  a.value = value if value
                  a.save
                end
              end

            end

            # Remove cancellations
            registrant_type.registrants.where(status: 'Cancelled').each do |registrant|
              person = Person.where(crs_profile_id: registrant.profile_id).first
              if person
                @org.remove_contact(person)
                @org.remove_role_from_person(person)
              end
            end
          end

          CrsImportMailer.completed(@org, email_address).deliver if email_address
        end
      rescue
        CrsImportMailer.failed(@org, email_address).deliver if email_address
        raise
      end
    else
      CrsImportMailer.failed(@org, email_address).deliver if email_address
      raise
    end
    nil
  end
end
