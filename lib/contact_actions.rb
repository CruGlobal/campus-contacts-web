module ContactActions
  
  def create_contact
    Person.transaction do
      params[:person] ||= {}
      params[:person][:email_address] ||= {}
      params[:person][:phone_number] ||= {}
      unless params[:person][:firstName].present?# && (params[:person][:email_address][:email].present? || params[:person][:phone_number][:number].present?)
        respond_to do |wants|
          wants.html { render :nothing => true }
          wants.json do 
            raise ApiErrors::MissingData, "First Name is a required field but was not provided"
          end
        end
        return
      end
      @person, @email, @phone = create_person(params[:person])
      if @person.save

        @questions = current_organization.all_questions.where("#{SurveyElement.table_name}.hidden" => false)

        save_survey_answers
  
        FollowupComment.create_from_survey(current_organization, @person, current_organization.all_questions, @answer_sheets)

        create_contact_at_org(@person, current_organization)
        if params[:assign_to_me] == 'true'
          ContactAssignment.where(person_id: @person.id, organization_id: current_organization.id).destroy_all
          ContactAssignment.create!(person_id: @person.id, organization_id: current_organization.id, assigned_to_id: current_person.id)
        end
        respond_to do |wants|
          wants.html { redirect_to :back }
          wants.mobile { redirect_to :back }
          wants.js do
            @assignments = ContactAssignment.where(person_id: @person.id, organization_id: current_organization.id).group_by(&:person_id)
            @roles = Hash[OrganizationalRole.active.where(organization_id: current_organization.id, role_id: Role::CONTACT_ID, person_id: @person).map {|r| [r.person_id, r]}]
            @answers = generate_answers([@person], current_organization, @questions)
          end
          wants.json { @person.to_hash_basic(current_organization) }
        end
      else
        errors = []
        errors << 'First name is required.' unless @person.firstName.present?
        errors << 'Phone number is not valid.' if @phone && !@phone.valid?
        errors << 'Email address is not valid.' if @email && !@email.valid?
        respond_to do |wants|
          wants.html do render :nothing => true 
            flash.now[:error] = errors.join('<br />')
            render 'add_contact'
          end
          wants.json do 
            raise ApiErrors::MissingData, errors.join(', ')
          end
        end
      end
    end
  end

end