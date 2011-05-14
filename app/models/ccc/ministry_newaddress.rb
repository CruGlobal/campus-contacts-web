class Ccc::MinistryNewaddress < ActiveRecord::Base
  set_primary_key :addressID
  set_table_name 'ministry_newaddress'
  belongs_to :ministry_person, :class_name => 'Ccc::MinistryPerson', :foreign_key => :fk_PersonID
  
  def merge(other)
    Ccc::MinistryNewaddress.transaction do
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
      other.destroy
      save(:validate => false)
    end
  end
end
