# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
OpenBallot::Application.config.secret_token = ENV['SECRET'] || 'S7W3WMV5vrOXD4I3E2AnAUPU6ZrGSUAnKK48NwxgFpo8o1ChOxJoLogNQ4wL' # You really ought to renamed .env-sample to .env and set this
