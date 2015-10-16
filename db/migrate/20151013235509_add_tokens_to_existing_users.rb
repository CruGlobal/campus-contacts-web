class AddTokensToExistingUsers < ActiveRecord::Migration
  def change
    # this was used to generate tokens, but we don't want to do that anymore
    # User.where(token: nil).find_each { |u| u.regenerate_token }
  end
end
