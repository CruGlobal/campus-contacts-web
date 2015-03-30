class Address < ActiveRecord::Base
	TYPES = {"Current" => "current", "Permanent" => "permanent", "Emergency 1" => "emergency1", "Emergency 2" => "emergency2"}
	validates_presence_of :address_type
  
  validate do |value|
    # Handle dupicate address_type
    address_type = value.address_type_before_type_cast || value.address_type || nil
    if address_type.present?
      person = Person.find(value.person_id)
      if address = person.addresses.find_by_address_type(address_type)
        available_types = TYPES.values - person.addresses.pluck(:address_type)
        if available_types.present?
          # Select other types
          self[:address_type] = available_types.first
        else
          # Replace if all types are taken
          # refer to remove_address_with_same_type
        end
      end
    else
      errors.add(:address_type, "can't be blank")
    end
  end

	belongs_to :person, touch: true
  before_create :remove_address_with_same_type
  
  def remove_address_with_same_type
    Address.where("addresses.person_id = ? AND addresses.address_type = ?", self.person_id, self.address_type).destroy_all
  end

	def display_html
	  ret_val = address1 || ''
		ret_val += '<br/>'+address2 unless address2.nil? || address2.empty?
		ret_val += '<br/>' unless ret_val.empty?
		ret_val += city+', ' unless city.nil? || city.empty?
		ret_val += state + ' ' unless state.nil?
		ret_val += zip unless zip.nil?
		ret_val += '<br/>'+country unless country.nil? || country.empty? || country == 'US' || country == 'USA'
		return ret_val
	end
	alias_method :to_s, :display_html

	def map_link
	  address = [address1, address2, city, state, zip, country].select {|a| a.to_s.strip.present?}.join('+')
	 "http://maps.google.com/maps?f=q&source=s_q&hl=en&q=#{address}"
	end

  def merge(other)
    Address.transaction do
      # We're only interested if the other address has been updated more recently
      if other.updated_at && updated_at && other.updated_at > updated_at
        # if any part of they physical address is there, copy all of it
        physical_address = %w{address1 address2 address3 address4 city state zip country}
        if other.attributes.slice(*physical_address).any? {|k,v| v.present?}
          other.attributes.slice(*physical_address).each do |k, v|
            self[k] = v
          end
        end
        # Now copy the rest as long as they're not blank
        other.attributes.except(*(%w{id created_at person_id} + physical_address))
        attributes.each do |k, v|
          next if %w{id created_at person_id}.include?(k)
          next if v == other.attributes[k]
          self[k] = case
                    when other.attributes[k].blank? then v
                    when v.blank? then other.attributes[k]
                    else
                      other.updated_at > updated_at ? other.attributes[k] : v
                    end
        end
        self['changedBy'] = 'MERGE'
      end
      MergeAudit.create!(mergeable: self, merge_looser: other)
      other.reload
      other.destroy
      save(validate: false)
    end
  end
end
