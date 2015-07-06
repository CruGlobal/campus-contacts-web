class AddNewInteractionTypesForOrganization2495 < ActiveRecord::Migration
  def up
    # Bridges at University of Washington - OrganizationID 2495
    if organization = Organization.where(id: 2495).first
      ["Basic Follow-up", "Discipleship / Leadership"].each do |new_type|
        InteractionType.where(name: new_type, organization_id: organization.id).first_or_create
      end
    end
  end

  def down
  end
end
