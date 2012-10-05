# Be sure to restart your server when you modify this file.
REDIS_SERVER=[{:host=>"localhost",:port=>"6379"}]
#Myreport::Application.config.session_store :cookie_store, key: '_myreport_session'
Myreport::Application.config.session_store :redis_store
Myreport::Application.config.session_options =
{
  :key => '_session_myreport',
  :expire_after => 60.minutes,
  :servers => REDIS_SERVER
}
# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
# Myreport::Application.config.session_store :active_record_store
