class Ccc::MinistryNewaddress < ActiveRecord::Base
  set_primary_key :addressID
  set_table_name 'ministry_newaddress'
  belongs_to :ministry_person, :class_name => 'Ccc::MinistryPerson', :foreign_key => :fk_PersonID
  
  def merge(other)
    Ccc::MinistryNewaddress.transaction do
      # We're only interested if the other address has been updated more recently
      if other.dateChanged && other.dateChanged > dateChanged
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
      MergeAudit.create!(:mergeable => self, :merge_looser => other)
      other.destroy
      save(:validate => false)
    end
  end
end
