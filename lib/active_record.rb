class ActiveRecord::Base

  def self.create_or_update(relation, attrs_to_update)
    if (incumbent = relation.first).nil?
      relation.create!(attrs_to_update)
    else
      incumbent.update_attributes(attrs_to_update)
      incumbent
    end
  end

end
