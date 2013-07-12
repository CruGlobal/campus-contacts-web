class InteractionFilter
  attr_accessor :interactions, :filters

  def initialize(filters, organization = nil)
    @filters = filters
    @organization = organization

    # strip extra spaces from filters
    @filters.collect { |k, v| @filters[k] = v.to_s.strip }

  end

  def filter(interactions)
    filtered_interactions = interactions

    if @filters[:ids]
      filtered_interactions = filtered_interactions.where('interactions.id' => @filters[:ids].split(','))
    end

    if @filters[:interaction_type_ids]
      filtered_interactions = filtered_interactions.where('interactions.interaction_type_id' => @filters[:interaction_type_ids].split(','))
    end

    if @filters[:receiver_ids]
      filtered_interactions = filtered_interactions.where('interactions.receiver_id' => @filters[:receiver_ids].split(','))
    end

    if @filters[:created_by_ids]
      filtered_interactions = filtered_interactions.where('interactions.created_by_id' => @filters[:created_by_ids].split(','))
    end

    if @filters[:updated_by_ids]
      filtered_interactions = filtered_interactions.where('interactions.updated_by_id' => @filters[:updated_by_ids].split(','))
    end

    if @filters[:initiator_ids]
      filtered_interactions = filtered_interactions.joins(:interaction_initiators).where('interaction_initiators.person_id IN (:initiator_ids) AND interaction_initiators.interaction_id = interactions.id AND interactions.organization_id = :org_id)', initiator_ids: @filters[:initiator_ids].split(','), org_id: @organization.id)
    end

    if @filters[:people_ids]
      filtered_interactions = filtered_interactions.joins(:interaction_initiators).where('(interaction_initiators.person_id IN (:people_ids) AND interaction_initiators.interaction_id = interactions.id) OR (interactions.receiver_id IN(:people_ids)) AND interactions.organization_id = :org_id', people_ids: @filters[:people_ids].split(','), org_id: @organization.id)
    end

    filtered_interactions
  end
end
