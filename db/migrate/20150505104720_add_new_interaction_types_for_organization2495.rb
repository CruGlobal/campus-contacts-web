class AddNewInteractionTypesForOrganization2495 < ActiveRecord::Migration
  def up
    # Bridges at University of Washington - OrganizationID 2495
    if organization = Organization.find_by_id(2495)
      ["Basic Follow-up", "Discipleship / Leadership"].each do |new_type|
        InteractionType.find_or_create_by_name_and_organization_id(new_type, organization.id)
      end
    end
  end

  def down
  end
end
