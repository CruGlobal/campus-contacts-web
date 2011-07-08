class ChangeIdentityOnAccessTokenAndAccessGrantToInteger < ActiveRecord::Migration
  def up
	change_column(:access_grants, :identity, :integer)
	change_column(:access_tokens, :identity, :integer)
  end

  def down
	change_column(:access_grants, :identity, :string)
	change_column(:access_tokens, :identity, :string)
  end
end
