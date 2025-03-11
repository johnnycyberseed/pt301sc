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

    # Get hostname from environment or use default
    hostname = System.get_env("PT301SC_HOSTNAME") || "localhost"

    # Get the Bandit configuration from the config files
    http_config = Application.get_env(:pt301sc, :bandit_http)
    https_config = Application.get_env(:pt301sc, :bandit_https)

    # Resolve system environment variables in port configuration
    http_config = resolve_port(http_config)
    https_config = resolve_port(https_config)

    # Check if we should start the servers
    start_servers = Application.get_env(:pt301sc, :start_servers, Mix.env() != :test)

    # Only start the servers if configured to do so
    children = if start_servers do
      [
        # Start the HTTP Plug server
        {Bandit, http_config},
        # Start the HTTPS Plug server
        {Bandit, https_config}
      ]
    else
      []
    end

    # Log server startup with port and URL information
    Logger.info("Starting PT301SC")

    if start_servers do
      http_port = Keyword.get(http_config, :port)
      https_port = Keyword.get(https_config, :port)

      Logger.info("HTTP server listening on port #{http_port}")
      Logger.info("HTTPS server listening on port #{https_port}")
      Logger.info("Application URLs:")
      Logger.info("  HTTP:  http://#{hostname}:#{http_port}/")
      Logger.info("  HTTPS: https://#{hostname}:#{https_port}/")
    end

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

  # Helper function to resolve system environment variables in port configuration
  defp resolve_port(config) do
    case Keyword.get(config, :port) do
      {:system, env_var, default} ->
        Keyword.put(config, :port, get_port_from_env(env_var, default))
      port when is_integer(port) ->
        config
    end
  end
end
