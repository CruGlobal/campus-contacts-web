class AddPersonSignatureIdAndRemovePersonIdAndOrganizationIdInSignatures < ActiveRecord::Migration
  def change
    add_reference(:signatures, :person_signature, index: true, after: :organization_id)
    remove_reference(:signatures, :person, index: true, foreign_key: true)
    remove_reference(:signatures, :organization, index: true, foreign_key: true)
  end
end