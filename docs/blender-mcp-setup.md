# Blender MCP Setup

Connect opencode to Blender via the [Model Context Protocol](https://modelcontextprotocol.io/) (MCP) for AI-assisted 3D work.

## How It Works

```
opencode  <═ HTTP ═>  MCP server (port 9191)  <═ TCP socket ═>  Blender addon (port 9876)
```

Three components:

1. **Blender addon** — runs inside Blender, listens on TCP port 9876
2. **MCP server** — bridges opencode and Blender, serves on HTTP port 9191
3. **opencode** — connects to the MCP server as a remote MCP

## Prerequisites

- [Blender 5.1+](https://www.blender.org/download/)
- [uv](https://docs.astral.sh/uv/getting-started/installation/) package manager
- [opencode](https://opencode.ai)

## Step 1: Install the Blender Addon

Download the addon from the [official releases](https://projects.blender.org/lab/blender_mcp/releases) and install it in Blender via **Edit > Preferences > Add-ons > Install from Disk**.

See the [official setup guide](https://www.blender.org/lab/mcp-server/) for detailed instructions.

Once installed, the addon opens a socket server on port 9876. You can verify it in Blender's addon preferences panel.

## Step 2: Clone the MCP Server

```bash
cd $HOME
git clone https://projects.blender.org/lab/blender_mcp.git
```

This clones the official Blender MCP server into `~/blender_mcp/`.

## Step 3: Start the MCP Server

From the project root, run:

```bash
just mcp
```

This project command starts the server in the background. Its underlying command is:

```bash
uv --directory ~/blender_mcp/mcp run blender-mcp --transport http --port 9191 &
```

The server connects to Blender on port 9876 and exposes an MCP endpoint on `http://127.0.0.1:9191`.

## Step 4: Configure opencode

Add the following to your project's `opencode.jsonc`:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "blender-mcp": {
      "type": "remote",
      "url": "http://127.0.0.1:9191",
      "enabled": true
    }
  }
}
```

## Usage

1. Open Blender with the addon enabled
2. Start the MCP server (Step 3)
3. Start opencode — it will connect to the running MCP server

## Troubleshooting

**"Connection refused" on the MCP server**

- Make sure Blender is running with the addon enabled
- The addon listens on port 9876 by default — check the addon preferences if you changed it

**opencode can't find the MCP server**

- Ensure the MCP server is running before starting opencode
- Check `curl -X POST http://127.0.0.1:9191/ -H "Content-Type: application/json" -H "Accept: application/json, text/event-stream" -d '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-03-26","capabilities":{},"clientInfo":{"name":"test","version":"0.1"}}}'` to verify the server is up

**MCP server hangs on startup**

- The official MCP server from `projects.blender.org` uses HTTP transport. Do not use `uvx blender-mcp` (the ahujasid package) — it uses a different transport and will hang.

## Resources

- [Official Blender MCP page](https://www.blender.org/lab/mcp-server/)
- [MCP server source](https://projects.blender.org/lab/blender_mcp)
- [Llama.cpp setup (reference)](https://projects.blender.org/lab/blender_mcp/wiki/Llama.cpp)
- [MCP protocol spec](https://modelcontextprotocol.io/)
- [opencode MCP docs](https://opencode.ai/docs/mcp-servers/)
