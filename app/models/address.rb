class Address < ActiveRecord::Base
	TYPES = {"Current" => "current", "Permanent" => "permanent", "Emergency 1" => "emergency1", "Emergency 2" => "emergency2"}
	validates_presence_of :address_type
	
	belongs_to :person, touch: true
	
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
    Ccc::MinistryNewaddress.transaction do
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
