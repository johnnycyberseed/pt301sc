defmodule TrackerShortcutMapperTest do
  use ExUnit.Case
  doctest TrackerShortcutMapper

  setup do
    # Define some sample redirection rules for testing
    # In a real application, these might come from a config or database
    mapping = %{
      "111111111" => "https://app.shortcut.com/mo-vintro/story/11111",
      "222222222" => "https://app.shortcut.com/mo-vintro/story/22222",
      "333333333" => "https://app.shortcut.com/mo-vintro/story/33333",
      "444444444" => "https://app.shortcut.com/mo-vintro/story/44444",
      "555555555" => "https://app.shortcut.com/mo-vintro/story/55555",
      "666666666" => "https://app.shortcut.com/mo-vintro/story/66666",
      "777777777" => "https://app.shortcut.com/mo-vintro/story/77777"
    }

    %{
      tracker_to_shortcut_id: mapping,
      mapper: TrackerShortcutMapper.new(mapping)
    }
  end

  describe "new/1" do
    test "creates a new mapper instance with the provided mapping", ctx do
      # Get the mapping from the mapper and verify it matches our original
      mapper = ctx.mapper
      assert %TrackerShortcutMapper{} = mapper
      assert mapper.mapping == ctx.tracker_to_shortcut_id
    end
  end

  describe "tracker_id_to_shortcut_url/2" do

    test "given a Tracker Story URL, returns the corresponding Shortcut URL", ctx do
      assert TrackerShortcutMapper.tracker_id_to_shortcut_url("https://www.pivotaltracker.com/stories/show/111111111", ctx.mapper) ==
               {:ok, "https://app.shortcut.com/mo-vintro/story/11111"}
    end

    test "given a Tracker Project URL, returns the corresponding Shortcut URL", ctx do
      assert TrackerShortcutMapper.tracker_id_to_shortcut_url("https://www.pivotaltracker.com/n/projects/2694117/stories/222222222", ctx.mapper) ==
               {:ok, "https://app.shortcut.com/mo-vintro/story/22222"}
    end

    test "given a Tracker Epic URL, redirects to the Homepage of Shortcut", ctx do
      assert TrackerShortcutMapper.tracker_id_to_shortcut_url("https://www.pivotaltracker.com/epic/show/5282015", ctx.mapper) ==
               {:error, :epics_not_supported}
    end

    test "given a Tracker Story URL with an unknown ID, returns an error tuple", ctx do
      assert TrackerShortcutMapper.tracker_id_to_shortcut_url("https://www.pivotaltracker.com/stories/show/999999999", ctx.mapper) ==
               {:error, :tracker_id_not_found}
    end

    test "given an unrecognized URL format, returns an error tuple", ctx do
      assert TrackerShortcutMapper.tracker_id_to_shortcut_url("https://www.pivotaltracker.com/unknown/show/123456789", ctx.mapper) ==
               {:error, :unrecognized_url_format}
    end
  end
end
