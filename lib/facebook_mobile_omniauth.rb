module OmniAuth
  module Strategies
    class Facebook < OAuth2

      MOBILE_USER_AGENTS = 'palm|blackberry|nokia|phone|midp|mobi|symbian|chtml|ericsson|minimo|' +
                                     'audiovox|motorola|samsung|telit|upg1|windows ce|ucweb|astel|plucker|' +
                                     'x320|x240|j2me|sgh|portable|sprint|docomo|kddi|softbank|android|mmp|' +
                                     'pdxgw|netfront|xiino|vodafone|portalmmm|sagem|mot-|sie-|ipod|up\\.b|' +
                                     'webos|amoi|novarra|cdm|alcatel|pocket|ipad|iphone|mobileexplorer|' +
                                     'mobile'

      def request_phase
        options[:scope] ||= "email,offline_access"
        options[:display] = mobile_request? ? 'touch' : 'page'
        super
      end

      def mobile_request?
        ua = Rack::Request.new(@env).user_agent.to_s
        ua.downcase =~ Regexp.new(MOBILE_USER_AGENTS)
      end

    end
  end
end