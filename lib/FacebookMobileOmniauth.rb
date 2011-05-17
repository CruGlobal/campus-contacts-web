require "rack"

# module Rack
#   class FacebookMobileOmniauth
#     def initialize(app)
#       @app = app
#     end
# 
#     MOBILE_USER_AGENTS =  'palm|blackberry|nokia|phone|midp|mobi|symbian|chtml|ericsson|minimo|' +
#                               'audiovox|motorola|samsung|telit|upg1|windows ce|ucweb|astel|plucker|' +
#                               'x320|x240|j2me|sgh|portable|sprint|docomo|kddi|softbank|android|mmp|' +
#                               'pdxgw|netfront|xiino|vodafone|portalmmm|sagem|mot-|sie-|ipod|up\\.b|' +
#                               'webos|amoi|novarra|cdm|alcatel|pocket|ipad|iphone|mobileexplorer|' +
#                               'mobile'
# 
#     def call(env)
#       request = Request.new(env)
#       if request.user_agent.to_s.downcase =~ Regexp.new(MOBILE_USER_AGENTS)
#         OmniAuth::Strategies::Facebook.display = 'touch'
#       else
#         OmniAuth::Strategies::Facebook.display = nil
#       end   
#       return @app.call(env)
#     end
#   end
# end