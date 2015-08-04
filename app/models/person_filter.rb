class PersonFilter
  attr_accessor :people, :filters

  def initialize(filters, organization = nil)
    @filters = filters
    @organization = organization

    # strip extra spaces from filters
    @filters.collect { |k, v| @filters[k] = v.to_s.strip }

  end

  def filter(people)
    filtered_people = people

    if @filters[:ids].present?
      filtered_people = filtered_people.where('people.id' => @filters[:ids].split(','))
    end

    if @filters[:surveys].present? && filtered_people.present?
      survey_filters = eval(@filters[:surveys])

      survey_ids = survey_filters.keys
      if survey_ids.present?
        # Filter by survey
        filtered_people = filtered_people.joins(:answer_sheets)
                                         .where("answer_sheets.survey_id" => survey_ids.split(','))
        # survey_scope = Person.build_survey_scope(@organization, survey_ids)
        # filtered_people = Person.filter_by_survey_scope(filtered_people, @organization, survey_scope)
      end

      survey_filters.each do |survey_id, survey_options|
        if survey = Survey.where(id: survey_id).first
          # Filter by survey answers
          options = survey_options["options"]
          if questions = survey_options["questions"]
            questions.each do |question_id, keyword|
              if question = survey.questions.where(id: question_id.to_i).first
                if question.kind == "TextField"
                  answer = keyword
                  option = options.present? && options[question_id.to_s].present? ? options[question_id.to_s] : "contains"
                  filtered_people = Person.filter_by_text_field_answer(filtered_people, @organization, survey, question, answer, option)

                elsif question.kind == "ChoiceField"
                  answer = keyword.is_a?(Array) ? keyword : keyword.split("~~")
                  option = options.present? && options[question_id.to_s].present? ? options[question_id.to_s] : "all"
                  filtered_people = Person.filter_by_choice_field_answer(filtered_people, @organization, survey, question, answer, option)
                elsif question.kind == "DateField"

                  answer = Hash.new
                  begin
                    answer = keyword
                  rescue; end

                  if answer['start_day'].present? && answer['start_month'].present? && answer['start_year'].present?
                    answer["start"] = "#{answer['start_year']}-#{'%02d' % answer['start_month'].to_i}-#{'%02d' % answer['start_day'].to_i}"
                  else
                    answer["start"] = ""
                  end
                  if answer['end_day'].present? && answer['end_month'].present? && answer['end_year'].present?
                    answer["end"] = "#{answer['end_year']}-#{'%02d' % answer['end_month'].to_i}-#{'%02d' % answer['end_day'].to_i}"
                  else
                    answer["end"] = ""
                  end

                  option = options.present? && options[question_id.to_s].present? ? options[question_id.to_s] : "contains"
                  filtered_people = Person.filter_by_date_field_answer(filtered_people, @organization, survey, question, answer, option)

                end
              end
            end
          end
        end
      end
    end

    if @filters[:fb_uids].present? && filtered_people.present?
      filtered_people = filtered_people.where('people.fb_uid' => @filters[:fb_uids].split(','))
    end

    if @filters[:labels].present? && filtered_people.present?
      label_ids = @filters[:labels].split(',').collect(&:to_i)
      if @filters[:option] == "all" && label_ids.count > 1
        filtered_people_ids = filtered_people.collect(&:id)
        label_ids.each do |label_id|
          filtered_people_ids = OrganizationalLabel.where(label_id: label_id, removed_date: nil, organization_id: @organization.id, person_id: filtered_people_ids).collect(&:person_id)
        end
        filtered_people = filtered_people.where('people.id' => filtered_people_ids)
      else
        filtered_people = filtered_people
                            .joins(:organizational_labels)
                            .where('organizational_labels.label_id IN (?) AND organizational_labels.organization_id = ? AND organizational_labels.removed_date IS NULL', label_ids, @organization.id)
      end
    end

    if @filters[:permissions].present? && filtered_people.present?
      filtered_people = filtered_people
                          .references(:organizational_permissions)
                          .where('organizational_permissions.permission_id IN (?) AND organizational_permissions.organization_id = ?', @filters[:permissions].split(','), @organization.id)
    end

    if @filters[:roles] && filtered_people.present?
      permission_ids = @filters[:roles].split(',').collect {|r| r.to_i > 0 ? r : Permission.where(name: r).first.try(:id)}.compact
      label_ids = @filters[:roles].split(',').collect {|r| r.to_i > 0 ? r : Label.where(name: r).first.try(:id)}.compact
      filtered_people = filtered_people.joins(:organizational_labels)
                                       .includes(:organizational_permissions)
                                       .references(:organizational_permissions)
                                       .where('(organizational_permissions.permission_id IN (:permission_ids)
                                                AND organizational_permissions.organization_id = :org_id)
                                                OR (organizational_labels.label_id IN (:label_ids)
                                                AND organizational_labels.organization_id = :org_id
                                                AND organizational_labels.removed_date IS NULL)',
                                              permission_ids: permission_ids, label_ids: label_ids, org_id: @organization.id)
    end

    if @filters[:interactions] && filtered_people.present?
      interaction_ids = @filters[:interactions].split(',').collect(&:to_i)
      if @filters[:option] == "all" && interaction_ids.count > 1
        filtered_people_ids = filtered_people.collect(&:id)
        interaction_ids.each do |interaction_id|
          filtered_people_ids = Interaction.where(interaction_type_id:  interaction_id, organization_id: @organization.id, deleted_at: nil, receiver_id: filtered_people_ids).collect(&:receiver_id)
        end
        filtered_people = filtered_people.where('people.id' => filtered_people_ids)
      else
        filtered_people = filtered_people
                            .includes(:interactions)
                            .references(:interactions)
                            .where('interactions.organization_id = ? AND interactions.deleted_at IS NULL AND interactions.interaction_type_id IN (?)', @organization.id, interaction_ids)
      end
    end
    if @filters[:first_name_like] && filtered_people.present?
      filtered_people = filtered_people.where("first_name like ? ", "#{@filters[:first_name_like]}%")
    end

    if @filters[:last_name_like] && filtered_people.present?
      filtered_people = filtered_people.where("last_name like ? ", "#{@filters[:last_name_like]}%")
    end

    if @filters[:is_friends_with] && filtered_people.present?
      friend_ids =  $redis.smembers(Friend.redis_key(@filters[:is_friends_with], :following))
      if friend_ids.present?
        filtered_people =  filtered_people.where('people.id' => friend_ids)
      else
        filtered_people = filtered_people.where('1=0')
      end
    end

    if @filters[:name_or_email_like] && filtered_people.present?
      case
      when @filters[:name_or_email_like].split(/\s+/).length > 1
        # Email addresses don't have spaces, so if there's a space, this is probably a name
        @filters[:name_like] = @filters.delete(:name_or_email_like)
      when @filters[:name_or_email_like].include?('@')
        # Names don't typically have @ signs
        @filters[:email_like] = @filters.delete(:name_or_email_like)
      else
        filtered_people = filtered_people
                            .includes(:email_addresses)
                            .where("concat(people.first_name,' ',people.last_name) LIKE :search OR people.first_name LIKE :search OR people.last_name LIKE :search OR email_addresses.email LIKE :search", {:search => "#{filters[:name_or_email_like]}%"})
                            .references(:email_addresses)
      end
    end

    if @filters[:name_like] && filtered_people.present?
      # See if they've typed a first and last name
      if @filters[:name_like].split(/\s+/).length > 1
        filtered_people = filtered_people.where("concat(first_name,' ',last_name) like ? ", "%#{@filters[:name_like]}%")
      else
        filtered_people = filtered_people.where("first_name like :search OR last_name like :search",
                                                 {search: "#{@filters[:name_like]}%"})
      end
    end

    if @filters[:email_like] && filtered_people.present?
      filtered_people = filtered_people
                          .includes(:email_addresses)
                          .references(:email_addresses)
                          .where("email_addresses.email LIKE ?", "%#{filters[:email_like]}%")
    end

    if @filters[:email_exact] && filtered_people.present?
      filtered_people = filtered_people
                          .includes(:email_addresses)
                          .references(:email_addresses)
                          .where("email_addresses.email = ?", filters[:email_exact])
    end

    if @filters[:gender] && filtered_people.present?
      if @filters[:gender] == "no_response"
        filtered_people = filtered_people.where("people.gender IS NULL OR people.gender = ''")
      elsif @filters[:gender] == "with_response"
        filtered_people = filtered_people.where("people.gender = 1 OR gender = 0")
      else
        genders = []
        @filters[:gender].split(",").each do |gender|
          gender = gender.first.downcase
          if ["1","m"].include?(gender)
            genders << 1
          elsif ["0","f"].include?(gender)
            genders << 0
          end
        end
        filtered_people = filtered_people.where(gender: genders) if genders.present?
      end
    end

    if @filters[:followup_status] && filtered_people.present?
      followup_statuses = @filters[:followup_status].split(',').collect{|x| x.gsub(" ", "").underscore}
      filtered_people = filtered_people.where('organizational_permissions.followup_status' => followup_statuses)
      filtered_people = filtered_people.includes(:organizational_permissions) unless filtered_people.to_sql.include?('`organizational_permissions`')
    end

    if @filters[:assigned_to] && filtered_people.present?
      if @filters[:assigned_to] == "anyone"
        assignments = @organization.contact_assignments.collect(&:person_id)
        filtered_people = filtered_people.where(id: assignments)
      elsif @filters[:assigned_to] == "no_one"
        assignments = @organization.contact_assignments.collect(&:person_id)
        filtered_people = filtered_people.where.not(id: assignments)
      else
        assigned_to_ids = @filters[:assigned_to].split(',').collect(&:to_i)
        filtered_people = filtered_people
                            .includes(:assigned_tos)
                            .references(:assigned_tos)
                            .where('contact_assignments.assigned_to_id' => assigned_to_ids, 'contact_assignments.organization_id' => @organization.id)
      end
    end

    filtered_people
  end
end
