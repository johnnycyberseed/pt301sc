defmodule TrackerShortcutWeb.Router do
  @moduledoc """
  Web router for the Tracker to Shortcut redirect service.
  Handles redirecting Tracker URLs to their Shortcut equivalents directly.
  This server will listen on the www.pivotaltracker.com domain and automatically redirect.
  """

  use Plug.Router
  require Logger

  # Use logger for request logging
  plug Plug.Logger

  # Basic Plug setup
  plug :match
  plug Plug.Parsers, parsers: [:urlencoded, :multipart]
  plug :dispatch

  # Get the tracker_shortcut_mapper from application env
  defp mapper do
    Application.get_env(:pt301sc, :tracker_shortcut_mapper)
  end

  # Handle redirects for story URLs in format: /story/show/ID
  get "/story/show/:id" do
    tracker_id = id
    handle_redirect(conn, tracker_id)
  end

  # Handle redirects for project story URLs in format: /n/projects/PROJECT_ID/stories/ID
  get "/n/projects/:project_id/stories/:id" do
    tracker_id = id
    handle_redirect(conn, tracker_id)
  end

  # Handle redirects for epic URLs in format: /epic/show/ID
  get "/epic/show/:id" do
    conn
    |> put_resp_header("location", "/error")
    |> resp(302, "Redirecting to error page")
    |> halt()
  end

  # Error page for when redirect fails
  get "/error" do
    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, """
    <!DOCTYPE html>
    <html>
      <head>
        <title>Redirection Error</title>
        <style>
          body {
            font-family: Arial, sans-serif;
            margin: 40px;
            line-height: 1.6;
          }
          .container {
            max-width: 800px;
            margin: 0 auto;
          }
          h1 {
            color: #d43f3a;
          }
        </style>
      </head>
      <body>
        <div class="container">
          <h1>Error: Unable to Redirect</h1>
          <p>We couldn't redirect you to the corresponding Shortcut story.</p>
          <p>Possible reasons:</p>
          <ul>
            <li>The Tracker story ID was not found in our mapping</li>
            <li>The URL format wasn't recognized</li>
            <li>You're trying to redirect an Epic (which isn't supported yet)</li>
          </ul>
        </div>
      </body>
    </html>
    """)
  end

  # Simple home page with info about the service
  get "/" do
    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, """
    <!DOCTYPE html>
    <html>
      <head>
        <title>Tracker to Shortcut Redirect Service</title>
        <style>
          body {
            font-family: Arial, sans-serif;
            margin: 40px;
            line-height: 1.6;
          }
          .container {
            max-width: 800px;
            margin: 0 auto;
          }
        </style>
      </head>
      <body>
        <div class="container">
          <h1>Tracker to Shortcut Redirect Service</h1>
          <p>This service automatically redirects Pivotal Tracker URLs to their corresponding Shortcut stories.</p>

          <h2>Supported URL Formats:</h2>
          <ul>
            <li>https://www.pivotaltracker.com/story/show/ID</li>
            <li>https://www.pivotaltracker.com/n/projects/PROJECT_ID/stories/ID</li>
          </ul>
        </div>
      </body>
    </html>
    """)
  end

  # Helper function to handle redirection
  defp handle_redirect(conn, tracker_id) do
    case Map.get(mapper().mapping, tracker_id) do
      nil ->
        # Temporary redirect (302) to the error page if ID not found
        conn
        |> put_resp_header("location", "/error")
        |> resp(302, "Redirecting to error page")
        |> halt()

      shortcut_url ->
        # Permanent redirect (301) to the Shortcut URL
        conn
        |> put_resp_header("location", shortcut_url)
        |> resp(301, "Redirecting to Shortcut")
        |> halt()
    end
  end

  # Catch-all route
  match _ do
    conn
    |> put_resp_header("location", "/error")
    |> resp(302, "Redirecting to error page")
    |> halt()
  end
end
