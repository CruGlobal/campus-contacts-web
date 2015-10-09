module V4
  class User < ActiveRecord::Base
    has_secure_token

    def ensure_has_token
      return if token.present?
      update_attribute :token, self.class.generate_unique_secure_token
    end
  end
end
