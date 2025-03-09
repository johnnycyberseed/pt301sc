defmodule Pt301sc.Application do
  @moduledoc """
  OTP Application specification for Pt301sc
  """

  use Application

  @impl true
  def start(_type, _args) do
    # Load the mapping from the JSON file
    # In a real application, you might want to make this configurable
    mapper = TrackerShortcutMapper.new_from_file("priv/story_mapping.json")

    # Store the mapper in the application environment for easy access
    Application.put_env(:pt301sc, :tracker_shortcut_mapper, mapper)

    children = [
      # Start the Plug server
      {Plug.Cowboy, scheme: :http, plug: TrackerShortcutWeb.Router, options: [port: 4000]}
    ]

    opts = [strategy: :one_for_one, name: Pt301sc.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
