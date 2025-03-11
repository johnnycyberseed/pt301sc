import Config

# Configure the Bandit server
config :pt301sc, :bandit_http,
  plug: TrackerShortcutWeb.Router,
  scheme: :http,
  port: {:system, "PT301SC_HTTP_PORT", 8080}

config :pt301sc, :bandit_https,
  plug: TrackerShortcutWeb.Router,
  scheme: :https,
  port: {:system, "PT301SC_HTTPS_PORT", 8443},
  certfile: "priv/cert/cert.pem",
  keyfile: "priv/cert/key.pem",
  cipher_suite: :strong,
  otp_app: :pt301sc

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
