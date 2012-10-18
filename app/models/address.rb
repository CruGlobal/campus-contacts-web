class Address < ActiveRecord::Base
	self.primary_key = 			"addressID"
	
	validates_presence_of :addressType
	
	belongs_to :person, foreign_key: "fk_PersonID"
	
	before_save :stamp
	
	def home_phone; homePhone; end
	def cell_phone; cellPhone; end
	def work_phone; workPhone; end
	
  #set dateChanged and changedBy
  def stamp
    self.dateChanged = Time.now
    self.changedBy = ApplicationController.application_name
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
	
	def phone_number
    phone = (self.homePhone && !self.homePhone.empty?) ? self.homePhone : self.cellPhone
    phone = (phone && !phone.empty?) ? phone : self.workPhone
    phone
	end
	
	def phone_numbers
	  unless @phone_numbers 
	    @phone_numbers = []
	    @phone_numbers << home_phone + ' (home)' unless home_phone.blank?
	    @phone_numbers << cell_phone + ' (cell)' unless cell_phone.blank?
	    @phone_numbers << work_phone + ' (work)' unless work_phone.blank?
    end
  	@phone_numbers
	end

  
  def merge(other)
    Ccc::MinistryNewaddress.transaction do
      # We're only interested if the other address has been updated more recently
      if other.dateChanged && dateChanged && other.dateChanged > dateChanged
        # if any part of they physical address is there, copy all of it
        physical_address = %w{address1 address2 address3 address4 city state zip country}
        if other.attributes.slice(*physical_address).any? {|k,v| v.present?}
          other.attributes.slice(*physical_address).each do |k, v|
            self[k] = v
          end
        end
        # Now copy the rest as long as they're not blank
        other.attributes.except(*(%w{addressID dateCreated fk_PersonID} + physical_address))
        attributes.each do |k, v|
          next if %w{addressID dateCreated fk_PersonID}.include?(k)
          next if v == other.attributes[k]
          self[k] = case
                    when other.attributes[k].blank? then v
                    when v.blank? then other.attributes[k]
                    else
                      other.dateChanged > dateChanged ? other.attributes[k] : v
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
