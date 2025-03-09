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
    handle_redirect_with_mapper(conn, tracker_id)
  end

  # Handle redirects for project story URLs in format: /n/projects/PROJECT_ID/stories/ID
  get "/n/projects/:project_id/stories/:id" do
    tracker_id = id
    handle_redirect_with_mapper(conn, tracker_id)
  end

  # Handle redirects for epic URLs in format: /epic/show/ID
  get "/epic/show/:id" do
    conn
    |> put_resp_header("location", "/error?reason=epics_not_supported")
    |> resp(302, "Redirecting to error page")
    |> halt()
  end

  # Error page for when redirect fails
  get "/error" do
    reason = conn.params["reason"] || "unknown"

    {title, message} = case reason do
      "tracker_id_not_found" ->
        {"Error: Story ID Not Found", "The Tracker story ID was not found in our mapping."}
      "epics_not_supported" ->
        {"Error: Epics Not Supported", "Epic URLs are not currently supported by this service."}
      "unrecognized_url_format" ->
        {"Error: Unrecognized URL Format", "The URL format wasn't recognized by our service."}
      _ ->
        {"Error: Unable to Redirect", "We couldn't redirect you to the corresponding Shortcut story."}
    end

    # Log 200 response for the error page
    Logger.info("200 response: Serving error page for reason '#{reason}'")

    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, """
    <!DOCTYPE html>
    <html>
      <head>
        <title>#{title}</title>
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
          <h1>#{title}</h1>
          <p>#{message}</p>
          <p><a href="/">Return to Home</a></p>
        </div>
      </body>
    </html>
    """)
  end

  # Simple home page with info about the service
  get "/" do
    # Log 200 response for the home page
    Logger.info("200 response: Serving home page")

    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, """
    <!DOCTYPE html>
    <html>
      <head>
        <title>PT301SC</title>
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
          section {
            margin-bottom: 30px;
          }
        </style>
      </head>
      <body>
        <div class="container">
          <h1>PT301SC</h1>
          <p>This service automatically redirects Pivotal Tracker URLs to their corresponding Shortcut stories.</p>

          <section>
            <h2>Supported URL Formats:</h2>
            <ul>
              <li>https://www.pivotaltracker.com/story/show/ID</li>
              <li>https://www.pivotaltracker.com/n/projects/PROJECT_ID/stories/ID</li>
            </ul>
          </section>

          <section>
            <h2>Service Limitations:</h2>
            <ul>
              <li>Epic URLs are not currently supported (e.g., https://www.pivotaltracker.com/epic/show/ID)</li>
              <li>Only stories that exist in our mapping database can be redirected</li>
              <li>URLs that don't match the supported formats cannot be redirected</li>
            </ul>
          </section>
        </div>
      </body>
    </html>
    """)
  end

  # Helper function to handle redirection using the mapper
  defp handle_redirect_with_mapper(conn, tracker_id) do
    # Use the TrackerShortcutMapper.tracker_url_to_shortcut_url function
    # instead of directly accessing the mapping
    url = "https://www.pivotaltracker.com/story/show/#{tracker_id}"
    case TrackerShortcutMapper.tracker_url_to_shortcut_url(url, mapper()) do
      {:ok, shortcut_url} ->
        # Log 301 redirect with the destination URL
        Logger.info("301 redirect: Redirecting from #{url} to #{shortcut_url}")

        # Permanent redirect (301) to the Shortcut URL
        conn
        |> put_resp_header("location", shortcut_url)
        |> resp(301, "Redirecting to Shortcut")
        |> halt()

      {:error, reason} ->
        # Temporary redirect (302) to the error page with specific reason
        conn
        |> put_resp_header("location", "/error?reason=#{reason}")
        |> resp(302, "Redirecting to error page")
        |> halt()
    end
  end

  # Catch-all route
  match _ do
    conn
    |> put_resp_header("location", "/error?reason=unrecognized_url_format")
    |> resp(302, "Redirecting to error page")
    |> halt()
  end
end
