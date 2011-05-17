module OmniAuth
  module Strategies
    class Facebook < OAuth2
      cattr_accessor :display # new

      def request_phase
        options[:scope] ||= "email,offline_access"
        options[:display] = OmniAuth::Strategies::Facebook.display || nil # new
        super
      end
    end
  end
end