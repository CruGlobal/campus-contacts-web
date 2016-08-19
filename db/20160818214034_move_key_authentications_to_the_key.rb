class MoveKeyAuthenticationsToTheKey < ActiveRecord::Migration
  def up
    Authentication.where(provider: 'key').each do |auth|
      begin
        auth.update!(provider: 'thekey')
      rescue ActiveRecord::RecordNotUnique
        # auth.destroy
      end
    end
  end

  def down
  end
end
