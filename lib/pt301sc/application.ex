defmodule Pt301sc.Application do
  @moduledoc """
  OTP Application specification for Pt301sc
  """

  use Application
  require Logger

  @impl true
  def start(_type, _args) do
    # Load the mapping from the JSON file
    # In a real application, you might want to make this configurable
    mapper = TrackerShortcutMapper.new_from_file("priv/story_mapping.json")

    # Store the mapper in the application environment for easy access
    Application.put_env(:pt301sc, :tracker_shortcut_mapper, mapper)

    # Get port configuration from environment or use defaults
    http_port = get_port_from_env("PT301SC_HTTP_PORT", 8080)
    https_port = get_port_from_env("PT301SC_HTTPS_PORT", 8443)

    # Get hostname from environment or use default
    hostname = System.get_env("PT301SC_HOSTNAME") || "localhost"

    # Define SSL options for HTTPS
    https_options = [
      port: https_port,
      cipher_suite: :strong,
      keyfile: "priv/cert/key.pem",
      certfile: "priv/cert/cert.pem",
      otp_app: :pt301sc
    ]

    children = [
      # Start the HTTP Plug server
      {Plug.Cowboy, scheme: :http, plug: TrackerShortcutWeb.Router, options: [port: http_port]},
      # Start the HTTPS Plug server
      {Plug.Cowboy, scheme: :https, plug: TrackerShortcutWeb.Router, options: https_options}
    ]

    # Log server startup with port and URL information
    Logger.info("Starting PT301SC")
    Logger.info("HTTP server listening on port #{http_port}")
    Logger.info("HTTPS server listening on port #{https_port}")
    Logger.info("Application URLs:")
    Logger.info("  HTTP:  http://#{hostname}:#{http_port}/")
    Logger.info("  HTTPS: https://#{hostname}:#{https_port}/")

    opts = [strategy: :one_for_one, name: Pt301sc.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Helper function to get port configuration from environment variables
  defp get_port_from_env(env_var, default) do
    case System.get_env(env_var) do
      nil -> default
      port_str ->
        case Integer.parse(port_str) do
          {port, ""} -> port
          _ ->
            IO.puts("Warning: Invalid port value for #{env_var}, using default #{default}")
            default
        end
    end
  end
end
