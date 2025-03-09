defmodule TrackerShortcutWebTest do
  use ExUnit.Case

  # We'll use bypass to mock HTTP requests
  # and plug_test to test our own Plug router
  use Plug.Test

  alias TrackerShortcutWeb.Router

  setup do
    # Define some sample redirection rules for testing
    mapping = %{
      "111111111" => "https://app.shortcut.com/mo-vintro/story/11111",
      "222222222" => "https://app.shortcut.com/mo-vintro/story/22222"
    }

    # Create our mapper and router for testing
    mapper = TrackerShortcutMapper.new(mapping)

    # Set up the application state
    # In a real app, this might be handled by your application supervision tree
    Application.put_env(:pt301sc, :tracker_shortcut_mapper, mapper)

    # Return the mapper for tests
    %{mapper: mapper}
  end

  describe "Story URL handling" do
    test "redirects Tracker story URL to Shortcut URL" do
      # Test the /story/show/:id format
      conn =
        :get
        |> conn("/story/show/111111111")
        |> Router.call([])

      # Verify we get a 301 redirect
      assert conn.status == 301
      assert get_resp_header(conn, "location") == ["https://app.shortcut.com/mo-vintro/story/11111"]
    end

    test "redirects Tracker project URL to Shortcut URL" do
      # Test the /n/projects/:project_id/stories/:id format
      conn =
        :get
        |> conn("/n/projects/2694117/stories/222222222")
        |> Router.call([])

      # Verify we get a 301 redirect
      assert conn.status == 301
      assert get_resp_header(conn, "location") == ["https://app.shortcut.com/mo-vintro/story/22222"]
    end

    test "redirects to error page when tracker ID not found" do
      conn =
        :get
        |> conn("/story/show/999999999")
        |> Router.call([])

      # We should get redirected to the error page
      assert conn.status == 302
      assert get_resp_header(conn, "location") == ["/error"]
    end

    test "redirects to error page for epic URLs" do
      conn =
        :get
        |> conn("/epic/show/5282015")
        |> Router.call([])

      # We should get redirected to the error page
      assert conn.status == 302
      assert get_resp_header(conn, "location") == ["/error"]
    end

    test "redirects to error page for invalid URL format" do
      conn =
        :get
        |> conn("/invalid/format/123456")
        |> Router.call([])

      # We should get redirected to the error page
      assert conn.status == 302
      assert get_resp_header(conn, "location") == ["/error"]
    end
  end

  describe "GET /error" do
    test "returns an error page" do
      conn =
        :get
        |> conn("/error")
        |> Router.call([])

      assert conn.status == 200
      assert conn.resp_body =~ "Error: Unable to Redirect"
    end
  end

  describe "GET /" do
    test "returns the home page" do
      conn =
        :get
        |> conn("/")
        |> Router.call([])

      assert conn.status == 200
      assert conn.resp_body =~ "Tracker to Shortcut Redirect Service"
      # No form on homepage anymore
      refute conn.resp_body =~ "<form"
    end
  end
end
