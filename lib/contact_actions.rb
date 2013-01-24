module ContactActions

  def create_contact
    @organization ||= current_organization

    Person.transaction do
      params[:person] ||= {}
      params[:person][:email_address] ||= {}
      params[:person][:phone_number] ||= {}
      unless params[:person][:first_name].present?# && (params[:person][:email_address][:email].present? || params[:person][:phone_number][:number].present?)
        respond_to do |wants|
          wants.html { render :nothing => true }
          wants.json do
            raise ApiErrors::MissingData, "First Name is a required field but was not provided"
          end
        end
        return
      end

      params[:answers].each do |answer|
        answers = []
        fields = answer[1]
        if fields.is_a?(Hash)
          # Read birth_date & graduation_date question from non-predefined survey
          fields.each do |key,val|
            if val.present? && date_question = Element.find_by_id(key.to_i)
              params[:person][:birth_date] = val if date_question.attribute_name == 'birth_date'
              params[:person][:graduation_date] = val if date_question.attribute_name == 'graduation_date'
              break unless @person.valid?
            end
          end
        else
          # Read birth_date & graduation_date question from predefined survey
          question_id = answer[0]
          if fields.present? && date_question = Element.find_by_id(question_id.to_i)
            params[:person][:birth_date] = fields if date_question.attribute_name == 'birth_date'
            params[:person][:graduation_date] = fields if date_question.attribute_name == 'graduation_date'
            break unless @person.valid?
          end
        end
      end if params[:answers]

      @person = Person.new_from_params(params[:person])
      @email = @person.email_addresses.first
      @phone = @person.phone_numbers.first

      if @person.save
        if params[:labels].present?
          params[:labels].each do |role_id|
            OrganizationalRole.find_or_create_by_person_id_and_organization_id_and_role_id(@person.id, current_organization.id, role_id, added_by_id: current_user.person.id) if role_id.present?
          end
        end

        @questions = @organization.all_questions.where("#{SurveyElement.table_name}.hidden" => false)
        save_survey_answers

        # Record that this person was created so we can notify leaders/admins
        NewPerson.create(person_id: @person.id, organization_id: @organization.id)

        create_contact_at_org(@person, @organization)
        @person.unachive_contact_role(@organization)

        if params[:assign_to_me] == 'true'
          ContactAssignment.where(person_id: @person.id, organization_id: @organization.id).destroy_all
          ContactAssignment.create!(person_id: @person.id, organization_id: @organization.id, assigned_to_id: current_person.id)
        end

				if @add_to_group_tag = params[:add_to_group_tag] == "true"
    			@group = @organization.groups.find(params[:add_to_group])
		      @group_membership = @group.group_memberships.find_or_initialize_by_person_id(@person.id)
		      @group_membership.role = params[:add_to_group_role]
		      @group_membership.save
				end
        
        respond_to do |wants|
          wants.html { redirect_to :back }
          wants.mobile { redirect_to :back }
          wants.js do
            @assignments = ContactAssignment.where(person_id: @person.id, organization_id: @organization.id).group_by(&:person_id)
            @roles = Hash[OrganizationalRole.active.where(organization_id: @organization.id, role_id: Role::CONTACT_ID, person_id: @person).map {|r| [r.person_id, r]}]
            @answers = generate_answers(Person.where(id: @person.id), @organization, @questions)
          end
          wants.json { render json: @person.to_hash_basic(@organization) }
        end
        return
      else
        errors = @person.errors.full_messages
        respond_to do |wants|
          wants.js do
            flash.now[:error] = errors.join('<br />')
            render 'add_contact'
          end
          wants.json do
            raise ApiErrors::MissingData, errors.join(', ')
          end
        end
        return false
      end
    end
  end

  def save_survey_answers
    @answer_sheets = []
    @organization ||= current_organization

    params[:answers].each do |answer|
      answers = []
      fields = answer[1]
      if fields.is_a?(Hash)
        # Save Non-Predefined Survey Answers
        survey_id = answer[0]
        if survey = @organization.surveys.find(survey_id)
          @answer_sheet = get_answer_sheet(survey, @person)
          question_set = QuestionSet.new(survey.questions, @answer_sheet)
          question_set.post(fields, @answer_sheet)
          question_set.save
          @answer_sheet.person.save
          @answer_sheets << @answer_sheet
        end
      else
        # Collect predefined survey answers
        answers << answer
      end
      if answers.present?
        # Save predefined survey answers
        @organization.surveys.each do |survey|
          @answer_sheet = get_answer_sheet(survey, @person)
          question_set = QuestionSet.new(survey.questions, @answer_sheet)
          question_set.post(answers, @answer_sheet)
          question_set.save
          @answer_sheet.person.save
          @answer_sheets << @answer_sheet
        end
      end
    end if params[:answers]

    # Delete any answer_sheet with no answers

    @answer_sheets.each do |as|
      if as.reload.answers.blank?
        as.destroy
        @answer_sheets -= [as]
      end
    end

    FollowupComment.create_from_survey(@organization, @person, @organization.all_questions, @answer_sheets)
  end

  def update_survey_answers
    @answer_sheets = []
    @organization ||= current_organization

    params[:answers].each do |answer|
      survey_id = answer[0]
      fields = answer[1]
      if survey = @organization.surveys.find(survey_id)
        @answer_sheet = get_answer_sheet(survey, @person)
        question_set = QuestionSet.new(survey.questions, @answer_sheet)
        question_set.post(fields, @answer_sheet)
        question_set.save
        @answer_sheet.person.save
        @answer_sheets << @answer_sheet
      end
    end

    # Delete any answer_sheet with no answers
    @answer_sheets.each do |as|
      if as.reload.answers.blank?
        as.destroy
        @answer_sheets -= [as]
      end
    end


  end

end
