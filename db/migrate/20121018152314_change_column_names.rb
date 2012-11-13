class ChangeColumnNames < ActiveRecord::Migration
  def change
    # Addresses table
    change_table :addresses, bulk: true do |t|
      t.rename :addressID, :id
      t.rename :addressType, :address_type
      t.rename :dateCreated, :created_at
      t.rename :dateChanged, :updated_at
      t.rename :fk_PersonID, :person_id
      t.remove :homePhone, :workPhone, :cellPhone, :fax, :email, :url, :contactName, :contactRelationship, :email2, :facebook_link, :myspace_link, :title, :preferredPhone, :phone1_type, :phone2_type, :phone3_type, :createdBy, :changedBy
    end
    
    # People table
    Person.where("preferredName is not null and preferredName <> ''").update_all("firstName = preferredName")
    change_table :people, bulk: true do |t|
      t.rename :personID, :id
      
      t.rename :firstName, :first_name
      t.rename :lastName, :last_name
      t.rename :middleName, :middle_name
      t.rename :yearInSchool, :year_in_school
      t.rename :greekAffiliation, :greek_affiliation
      t.rename :dateCreated, :created_at
      t.rename :dateChanged, :updated_at
      t.rename :fk_ssmUserId, :user_id
      t.remove :preferredName, :region, :workInUs, :usCitizen, :citizenship, :isStaff, :title, :universityState, :maritalStatus, :numberChildren, :isChild, :bio, :image,
               :occupation, :blogfeed, :cruCommonsInvite, :cruCommonsLastLogin, :createdBy, :changedBy, :donor_number, :url, :isSecure, :lastAttended, :ministry, :strategy, 
               :balance_daily, :fk_StaffSiteProfileID, :fk_spouseID, :fk_childOf
    end
    
    # Users
    change_table :users do |t|
      t.rename :userID, :id
      t.remove :globallyUniqueID, :passwordQuestion, :passwordAnswer, :lastFailure, :lastFailureCnt, :emailVerified, :facebook_hash, :facebook_username,
               :fb_user_id, :password_plain, :password_reset_key, :checked_guid
    end
  
  end
end