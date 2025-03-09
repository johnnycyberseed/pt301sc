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
  Creates a new TrackerShortcutMapper instance by loading a mapping from a JSON file.

  The JSON file should contain a map where keys are Tracker IDs and values are Shortcut URLs.

  ## Examples

      # This is just a representative example - actual output will have the full mapping
      iex> mapper = TrackerShortcutMapper.new_from_file("test/fixture/vintro-story-mapping.json")
      iex> is_map(mapper.mapping)
      true
      iex> Map.has_key?(mapper.mapping, "188732660")
      true

  Raises `File.Error` if the file does not exist.
  Raises an `ErlangError` if the file is not valid JSON.
  """
  def new_from_file(file_path) when is_binary(file_path) do
    mapping = file_path
      |> File.read!()
      |> decode_json()
      |> ensure_string_keys_and_values()

    new(mapping)
  end

  # Wrapper for json decoding to handle any errors
  defp decode_json(json_string) do
    try do
      :json.decode(json_string)
    rescue
      error -> raise error
    end
  end

  # Helper function to ensure all keys and values are strings
  defp ensure_string_keys_and_values(map) when is_map(map) do
    map
    |> Enum.map(fn {k, v} -> {to_string(k), to_string(v)} end)
    |> Enum.into(%{})
  end

  @doc """
  Converts a Pivotal Tracker URL to a Shortcut URL.

  Takes a Tracker URL and a TrackerShortcutMapper instance,
  extracts the Tracker ID from the URL, and returns the corresponding Shortcut URL.

  ## Examples

      iex> mapping = %{"111111111" => "https://app.shortcut.com/org/story/11111"}
      iex> mapper = TrackerShortcutMapper.new(mapping)
      iex> TrackerShortcutMapper.tracker_url_to_shortcut_url("https://www.pivotaltracker.com/stories/show/111111111", mapper)
      {:ok, "https://app.shortcut.com/org/story/11111"}

  """
  def tracker_url_to_shortcut_url(url, %__MODULE__{} = mapper) do
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
