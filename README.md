# Tracker to Shortcut Redirector

A web server that automatically redirects Pivotal Tracker URLs to their corresponding Shortcut story URLs.

## Description

This service is designed to be deployed to handle requests for the `www.pivotaltracker.com` domain, automatically redirecting users to the equivalent Shortcut story. It uses a mapping file to convert between Tracker story IDs and Shortcut URLs.

## Features

- Automatic redirection from Tracker URLs to Shortcut URLs
- Supports multiple Tracker URL formats:
  - `/story/show/ID`
  - `/n/projects/PROJECT_ID/stories/ID`
- Returns appropriate error pages for unmapped IDs or unsupported URL types (like Epics)
- 301 permanent redirects to maintain SEO and bookmarks

## Installation

```bash
# Clone the repository
git clone <repository_url>
cd pt301sc

# Install dependencies
mix deps.get
```

## Configuration

The application reads the mapping between Tracker IDs and Shortcut URLs from a JSON file located at `priv/story_mapping.json`. This file should have the following format:

```json
{
  "111111111": "https://app.shortcut.com/your-org/story/11111",
  "222222222": "https://app.shortcut.com/your-org/story/22222"
}
```

Where each key is a Tracker story ID and each value is the corresponding Shortcut URL.

## Running the Server

To start the web server:

```bash
# Start the server
mix run --no-halt
```

By default, the server runs on port 4000, so you can access it at [http://localhost:4000/](http://localhost:4000/).

To test the redirect functionality, visit:
- [http://localhost:4000/story/show/111111111](http://localhost:4000/story/show/111111111)
- [http://localhost:4000/n/projects/2694117/stories/222222222](http://localhost:4000/n/projects/2694117/stories/222222222)

## Running in Production

For production deployment, you can build a release:

```bash
MIX_ENV=prod mix release
```

Then run the release:

```bash
_build/prod/rel/pt301sc/bin/pt301sc start
```

## Testing

To run the tests:

```bash
mix test
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/pt301sc>.

