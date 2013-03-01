class ContactAssignmentFilter
  attr_accessor :contact_assignments, :filters

  def initialize(filters)
    @filters = filters

    # strip extra spaces from filters
    @filters.collect { |k, v| @filters[k] = v.strip }
  end

  def filter(contact_assignments)
    filtered = contact_assignments

    if @filters[:ids]
      filtered = filtered.where('contact_assignments.id' => @filters[:ids].split(','))
    end

    if @filters[:assigned_to_id]
      filtered = filtered.where('contact_assignments.assigned_to_id' => @filters[:assigned_to_id].split(','))
    end

    if @filters[:person_id]
      filtered = filtered.where('contact_assignments.person_id' => @filters[:person_id].split(','))
    end

    filtered
  end
end
