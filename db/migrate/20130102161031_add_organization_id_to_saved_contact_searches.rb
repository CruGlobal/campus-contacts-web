class AddOrganizationIdToSavedContactSearches < ActiveRecord::Migration
  def change
    add_column :saved_contact_searches, :organization_id, :integer
	 	SavedContactSearch.where("organization_id IS NULL").each do |saved_search|
			saved_search.update_attribute('organization_id', saved_search.user.person.primary_organization.id)
		end
  end
end

