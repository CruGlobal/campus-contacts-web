class AddTokensToExistingUsers < ActiveRecord::Migration
  def change
    User.where(token: nil).find_each { |u| u.regenerate_token }
  end
end
