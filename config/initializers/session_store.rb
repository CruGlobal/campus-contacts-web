# Be sure to restart your server when you modify this file.

require 'action_dispatch/middleware/session/dalli_store'
Mh::Application.config.session_store ActionDispatch::Session::CacheStore, :namespace => 'sessions', :key => '_mh_session', :expire_after => 2.days
# Mh::Application.config.session_store :cookie_store, key: '_mh_session'
# Mh::Application.config.session_store :mem_cache_store, key: '_mh_session'
# Mh::Application.config.session_store :active_record, key: '_mh_session'
