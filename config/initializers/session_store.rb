# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_simpic_session',
  :secret      => '066e272906b6b22547bd63c8a3061025a72e28ad5f1008332ebc30aff666e43baed9c3b6ce6c3ec2aa6cc4725cbc3431f79b34ac0627bb12a30ae26330adaf61'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
