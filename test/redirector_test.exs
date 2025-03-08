defmodule RedirectorTest do
  use ExUnit.Case
  doctest Redirector

  setup do
    # Define some sample redirection rules for testing
    # In a real application, these might come from a config or database
    %{
      tracker_to_shortcut_id: %{
        "111111111" => "https://app.shortcut.com/mo-vintro/story/11111",
        "222222222" => "https://app.shortcut.com/mo-vintro/story/22222",
        "333333333" => "https://app.shortcut.com/mo-vintro/story/33333",
        "444444444" => "https://app.shortcut.com/mo-vintro/story/44444",
        "555555555" => "https://app.shortcut.com/mo-vintro/story/55555",
        "666666666" => "https://app.shortcut.com/mo-vintro/story/66666",
        "777777777" => "https://app.shortcut.com/mo-vintro/story/77777"
      }
    }
  end

  describe "tracker_id_to_shortcut_url/2" do
    test "given a Tracker URL with 'stories/show' format, returns the corresponding Shortcut URL", ctx do
      assert Redirector.tracker_id_to_shortcut_url("https://www.pivotaltracker.com/stories/show/111111111", ctx.tracker_to_shortcut_id) ==
               "https://app.shortcut.com/mo-vintro/story/11111"
    end

    test "given a Tracker URL with 'projects/ID/stories' format, returns the corresponding Shortcut URL", ctx do
      assert Redirector.tracker_id_to_shortcut_url("https://www.pivotaltracker.com/n/projects/2694117/stories/222222222", ctx.tracker_to_shortcut_id) ==
               "https://app.shortcut.com/mo-vintro/story/22222"
    end
  end
end
