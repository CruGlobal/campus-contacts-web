class Address < ActiveRecord::Base
  set_table_name				"ministry_newaddress"
	set_primary_key 			"addressID"
	
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
		ret_val += '<br/>'+country+',' unless country.nil? || country.empty? || country == 'USA'
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
end
