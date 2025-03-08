defmodule Redirector do
  @moduledoc """
  Handles redirection logic for the application.
  """

  @doc """
  Converts a Pivotal Tracker URL to a Shortcut URL.

  Accepts a Tracker URL and a mapping of Tracker IDs to Shortcut URLs,
  extracts the Tracker ID from the URL, and returns the corresponding Shortcut URL.

  ## Examples

      iex> mapping = %{"111111111" => "https://app.shortcut.com/org/story/11111"}
      iex> Redirector.tracker_id_to_shortcut_url("https://www.pivotaltracker.com/stories/show/111111111", mapping)
      "https://app.shortcut.com/org/story/11111"

  """
  def tracker_id_to_shortcut_url(url, tracker_to_shortcut_id) do
    tracker_id = extract_tracker_id(url)
    Map.get(tracker_to_shortcut_id, tracker_id)
  end

  @doc """
  Extracts the Tracker ID from a Pivotal Tracker URL.

  Handles different URL formats:
  - https://www.pivotaltracker.com/stories/show/ID
  - https://www.pivotaltracker.com/n/projects/PROJECT_ID/stories/ID

  Returns the extracted ID as a string.
  """
  def extract_tracker_id(url) do
    cond do
      # Format: https://www.pivotaltracker.com/stories/show/111111111
      String.match?(url, ~r{/stories/show/(\d+)}) ->
        [[_, id]] = Regex.scan(~r{/stories/show/(\d+)}, url)
        id

      # Format: https://www.pivotaltracker.com/n/projects/2694117/stories/222222222
      String.match?(url, ~r{/projects/\d+/stories/(\d+)}) ->
        [[_, id]] = Regex.scan(~r{/projects/\d+/stories/(\d+)}, url)
        id

      true ->
        nil
    end
  end
end
