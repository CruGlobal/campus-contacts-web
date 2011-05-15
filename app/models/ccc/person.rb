module Ccc
  module Person
    extend ActiveSupport::Concern
    
    included do
      # has_many :crs2_profiles, :class_name => 'Ccc::Crs2Profile', :dependent => :destroy
      # has_many :ministry_missional_team_members, :class_name => 'Ccc::MinistryMissionalTeamMember', :dependent => :destroy
      has_many :ministry_newaddresses, :class_name => 'Ccc::MinistryNewaddress', :foreign_key => :fk_PersonID, :dependent => :destroy
      # has_many :organization_memberships, :class_name => 'Ccc::OrganizationMembership', :dependent => :destroy
      # has_many :sn_timetables, :class_name => 'Ccc::SnTimetable', :dependent => :destroy
      # has_many :sp_staff, :class_name => 'Ccc::SpStaff', :dependent => :destroy
      # has_one :sp_user, :class_name => 'Ccc::SpUser', :dependent => :destroy
    end
    
    module InstanceMethods
      def merge(other)
        ::Person.transaction do
          attributes.each do |k, v|
            next if k == ::Person.primary_key
            next if v == other.attributes[k]
            self[k] = case
                      when other.attributes[k].blank? then v
                      when v.blank? then other.attributes[k]
                      else
                        other.dateChanged > dateChanged ? other.attributes[k] : v
                      end
          end
          
          # Addresses
          ministry_newaddresses.each do |address|
            other_address = other.ministry_newaddresses.detect {|oa| oa.addressType == address.addressType}
            address.merge(other_address) if other_address
          end
          other.ministry_newaddresses.each {|pn| ma.update_attribute(:fk_PersonID, id) unless ma.frozen?}
          
          MergeAudit.create!(:mergeable => self, :merge_looser => other)
          other.destroy
          save(:validate => false)
        end
      end
    end
  end
end
