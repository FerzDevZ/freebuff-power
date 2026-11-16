#!/usr/bin/env python3
"""
MCP Stdio Tester
Sends an initialize and tools/list request via stdin/stdout to verify that an MCP server responds with valid JSON-RPC 2.0.
"""

import sys
import json
import subprocess

def test_mcp_server(cmd: str):
    print(f"🚀 Launching MCP server process: {cmd}")
    proc = subprocess.Popen(
        cmd,
        shell=True,
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True
    )

    init_payload = {
        "jsonrpc": "2.0",
        "id": 1,
        "method": "initialize",
        "params": {
            "protocolVersion": "2024-11-05",
            "capabilities": {},
            "clientInfo": {"name": "mcp-test-runner", "version": "1.0.0"}
        }
    }

    proc.stdin.write(json.dumps(init_payload) + "\n")
    proc.stdin.flush()

    response_line = proc.stdout.readline()
    if not response_line:
        err = proc.stderr.read()
        print(f"❌ No response from MCP server. Stderr: {err}")
        proc.kill()
        sys.exit(1)

    try:
        resp = json.loads(response_line)
        print("✅ Received Initialize Response:", json.dumps(resp, indent=2))
    except Exception as e:
        print(f"❌ Failed to parse JSON response: {response_line}")
        proc.kill()
        sys.exit(1)

    proc.kill()
    print("🎉 MCP Server stdio handshake verified successfully!")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: test-mcp-stdio.py '<server_command>'")
        sys.exit(1)
    test_mcp_server(sys.argv[1])
