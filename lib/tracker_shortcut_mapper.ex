defmodule TrackerShortcutMapper do
  @moduledoc """
  Handles mapping of Pivotal Tracker URLs to Shortcut URLs.
  """

  defstruct [:mapping]

  @doc """
  Creates a new TrackerShortcutMapper instance with the provided mapping.

  ## Examples

      iex> mapping = %{"111111111" => "https://app.shortcut.com/org/story/11111"}
      iex> TrackerShortcutMapper.new(mapping)
      %TrackerShortcutMapper{mapping: %{"111111111" => "https://app.shortcut.com/org/story/11111"}}

  """
  def new(mapping) when is_map(mapping) do
    %__MODULE__{mapping: mapping}
  end

  @doc """
  Converts a Pivotal Tracker URL to a Shortcut URL.

  Takes a Tracker URL and a TrackerShortcutMapper instance,
  extracts the Tracker ID from the URL, and returns the corresponding Shortcut URL.

  ## Examples

      iex> mapping = %{"111111111" => "https://app.shortcut.com/org/story/11111"}
      iex> mapper = TrackerShortcutMapper.new(mapping)
      iex> TrackerShortcutMapper.tracker_id_to_shortcut_url("https://www.pivotaltracker.com/stories/show/111111111", mapper)
      {:ok, "https://app.shortcut.com/org/story/11111"}

  """
  def tracker_id_to_shortcut_url(url, %__MODULE__{} = mapper) do
    case extract_tracker_id(url) do
      {:epic, _} -> {:error, :epics_not_supported}
      {:error, reason} -> {:error, reason}
      id ->
        case Map.get(mapper.mapping, id) do
          nil -> {:error, :tracker_id_not_found}
          shortcut_url -> {:ok, shortcut_url}
        end
    end
  end

  @doc """
  Extracts the Tracker ID from a Pivotal Tracker URL.

  Handles different URL formats:
  - https://www.pivotaltracker.com/stories/show/ID
  - https://www.pivotaltracker.com/n/projects/PROJECT_ID/stories/ID
  - https://www.pivotaltracker.com/epic/show/ID (returns {:epic, ID})

  Returns the extracted ID as a string, or {:epic, ID} for epic URLs.
  """
  def extract_tracker_id(url) do
    cond do
      # Format: https://www.pivotaltracker.com/epic/show/5282015
      String.match?(url, ~r{/epic/show/(\d+)}) ->
        [[_, id]] = Regex.scan(~r{/epic/show/(\d+)}, url)
        {:epic, id}

      # Format: https://www.pivotaltracker.com/stories/show/111111111
      String.match?(url, ~r{/stories/show/(\d+)}) ->
        [[_, id]] = Regex.scan(~r{/stories/show/(\d+)}, url)
        id

      # Format: https://www.pivotaltracker.com/n/projects/2694117/stories/222222222
      String.match?(url, ~r{/projects/\d+/stories/(\d+)}) ->
        [[_, id]] = Regex.scan(~r{/projects/\d+/stories/(\d+)}, url)
        id

      true ->
        {:error, :unrecognized_url_format}
    end
  end
end
