require 'omniauth/strategies/facebook'
module OmniAuth 
 module Strategies 
   class FacebookMhub < Strategies::Facebook 
      def name 
         :facebook_mhub
      end 
   end 
 end 
end 