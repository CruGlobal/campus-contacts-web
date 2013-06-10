class PersonFilter
  attr_accessor :people, :filters

  def initialize(filters)
    @filters = filters

    # strip extra spaces from filters
    @filters.collect { |k, v| @filters[k] = v.to_s.strip }
  end

  def filter(people)
    filtered_people = people

    if @filters[:ids]
      filtered_people = filtered_people.where('people.id' => @filters[:ids].split(','))
    end

    if @filters[:permissions]
      filtered_people = filtered_people.where('organizational_permissions.permission_id' => @filters[:permissions].split(','))
    end

    if @filters[:first_name_like]
      filtered_people = filtered_people.where("first_name like ? ", "#{@filters[:first_name_like]}%")
    end

    if @filters[:last_name_like]
      filtered_people = filtered_people.where("last_name like ? ", "#{@filters[:last_name_like]}%")
    end

    if @filters[:name_or_email_like]
      case
      when @filters[:name_or_email_like].split(/\s+/).length > 1
        # Email addresses don't have spaces, so if there's a space, this is probably a name
        @filters[:name_like] = @filters.delete(:name_or_email_like)
      when @filters[:name_or_email_like].include?('@')
        # Names don't typically have @ signs
        @filters[:email_like] = @filters.delete(:name_or_email_like)
      else
        filtered_people = filtered_people.includes(:email_addresses)
                                         .where("concat(first_name,' ',last_name) LIKE :search OR
                                                  email_addresses.email LIKE :search",
                                                 {:search => "#{filters[:name_or_email_like]}%"})
      end
    end

    if @filters[:name_like]
      # See if they've typed a first and last name
      if @filters[:name_like].split(/\s+/).length > 1
        filtered_people = filtered_people.where("concat(first_name,' ',last_name) like ? ", "%#{@filters[:name_like]}%")
      else
        filtered_people = filtered_people.where("first_name like :search OR last_name like :search",
                                                 {search: "#{@filters[:name_like]}%"})
      end
    end

    if @filters[:email_like]
      filtered_people = filtered_people.includes(:email_addresses)
                                         .where("email_addresses.email LIKE :search",
                                                 {:search => "#{filters[:name_or_email_like]}%"})
    end

    if @filters[:gender]
      gender = case
               when @filters[:gender].first.downcase == 'm'
                 1
               when @filters[:gender].first.downcase == 'f'
                 0
               else
                 @filters[:gender]
               end

      filtered_people = filtered_people.where(gender: gender)
    end

    if @filters[:followup_status]
      filtered_people = filtered_people.where('organizational_permissions.followup_status' => @filters[:followup_status].split(','))
      filtered_people = filtered_people.includes(:organizational_permissions) unless filtered_people.to_sql.include?('`organizational_permissions`')
    end

    if @filters[:assigned_to]
      filtered_people = filtered_people.includes(:assigned_tos)
                                        .where('contact_assignments.assigned_to_id' => @filters[:assigned_to].split(','))
    end

      if @filters[:surveys].present?
        filtered_people = filtered_people.joins(:answer_sheets)
                                         .where("answer_sheets.survey_id" => @filters[:surveys].split(','))
      end

    filtered_people
  end
end
