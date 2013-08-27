module ContactActions

  def create_contact
    @organization ||= current_organization
    @add_to_group_tag = params[:add_to_group_tag]
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

      # Initialize Person or get the existing person data
      @person = Person.new_from_params(params[:person])
      @email = @person.email_addresses.first
      @phone = @person.phone_numbers.first

      # This would set the selected values to the add contact form fields if there's an error messages
      flash[:selected_labels] = params[:labels]
      flash[:selected_answers] = params[:answers]
      flash[:selected_permissions] = params[:permissions_ids]
      flash[:add_to_group_tag] = @add_to_group_tag

      form_email_address = params[:person][:email_address][:email].to_s.strip
      form_first_name = params[:person][:first_name].to_s.strip
      form_last_name = params[:person][:last_name].to_s.strip
      custom_errors = Array.new

      # Validation if email address has value, first name and last name should be required
      if form_email_address.present? && (form_first_name.blank? || form_last_name.blank?)
        custom_errors << t("contacts.index.no_name_message")
      end

      # Validation existing person email address, create duplicate person and email if name does not match
      if form_email_address.present? && form_first_name.present? && form_last_name.present?
        if get_person = Person.find_existing_person_by_email(form_email_address)
          get_first_name = get_person.first_name.downcase.strip
          get_last_name = get_person.last_name.downcase.strip
          form_first_name = form_first_name.downcase.strip
          form_last_name = form_last_name.downcase.strip
          if get_person.organizational_permissions.where(:organization_id => current_organization).first
            custom_errors << t("contacts.index.add_already_registered_contact")
          end
          if custom_errors.present? || get_first_name != form_first_name || get_last_name != form_last_name
            @person = Person.new(params[:person].except(:email_address, :phone_number))
            @person.email_address = params[:person][:email_address]
            @person.phone_number = params[:person][:phone_number]
          end
        end
      end

      # Validation that requires the email if the permission is set to User or Admin
      if params[:permissions_ids].present? && Permission.is_set_to_user_or_admin?(params[:permissions_ids].first.to_i)
        unless form_email_address.present?
          if permission_name = Permission.find_by_id(params[:permissions_ids])
            custom_errors << t("contacts.index.for_this_permission_email_is_required", :permission => permission_name)
          else
            custom_errors << t("contacts.index.for_this_permission_email_is_required_no_name")
          end
        end
      end

      # # validation for existing phone number
      #if @person.phone_numbers.present?
      #  phone_numbers = @person.phone_numbers.collect(&:number)
      #  phone_numbers.each do |number|
      #    check_person = Person.find_existing_person_by_name_and_phone({first_name: params[:person][:first_name],
      #                                                           last_name:params[:person][:last_name],
      #                                                           number: number})
      #    unless check_person.present?
      #      custom_errors << "Phone number '#{number}' already in use" if PhoneNumber.find_by_number(number)
      #    end
      #  end
      #end

      if custom_errors.present?
        # Include the @person errors if invalid
        unless @person.valid?
          custom_errors = @person.errors.full_messages + custom_errors
        end

        respond_to do |wants|
          wants.js do
            flash.now[:error] = custom_errors.join('<br />')
            render 'add_contact'
          end
          wants.json do
            raise ApiErrors::MissingData, custom_errors.join(', ')
          end
        end
        return false
      end

      if @person.save
        if params[:labels].present?
          params[:labels].each do |label_id|
            OrganizationalLabel.find_or_create_by_person_id_and_organization_id_and_label_id(@person.id, current_organization.id, label_id, added_by_id: current_person.id) if label_id.present?
          end
        end

        # Save survey answers
        save_survey_answers

        # Record that this person was created so we can notify leaders/admins
        NewPerson.create(person_id: @person.id, organization_id: @organization.id)

        if params[:permissions_ids].present?
          @organization.add_permission_to_person(@person, params[:permissions_ids].first.to_i, current_person.id)
        else
          @organization.add_permission_to_person(@person, Permission::NO_PERMISSIONS_ID, current_person.id)
        end

        # create_contact_at_org(@person, @organization)
        # @person.unachive_contact_permission(@organization)

        if params[:assign_to_me] == 'true'
          ContactAssignment.where(person_id: @person.id, organization_id: @organization.id).destroy_all
          ContactAssignment.create!(person_id: @person.id, organization_id: @organization.id, assigned_to_id: current_person.id)
        end

				if @add_to_group_tag == '1'
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
            @permissions = Hash[OrganizationalPermission.active.where(organization_id: @organization.id, permission_id: Permission::NO_PERMISSIONS_ID, person_id: @person).map {|r| [r.person_id, r]}]

            initialize_surveys_and_questions
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
