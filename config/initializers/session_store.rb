# Be sure to restart your server when you modify this file.

require 'action_dispatch/middleware/session/dalli_store'
Mh::Application.config.session_store :dalli_store, :memcache_server => ['10.10.11.166','10.10.11.167'], :namespace => 'sessions', :key => '_mh_session', :expire_after => 2.days
# Mh::Application.config.session_store :cookie_store, key: '_mh_session'
# Mh::Application.config.session_store :mem_cache_store, key: '_mh_session'
# Mh::Application.config.session_store :active_record, key: '_mh_session'