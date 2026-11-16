#!/usr/bin/env python3
"""
JWT Security Inspector
Analyzes JWT unverified header and payload structure for common security vulnerabilities (alg: none, weak HMAC on public APIs, excessive expiry).
"""

import sys
import json
import base64
import time

def b64_decode(data: str) -> str:
    data += '=' * (-len(data) % 4)
    return base64.urlsafe_b64decode(data.encode('utf-8')).decode('utf-8', errors='ignore')

def inspect_jwt(token: str):
    parts = token.strip().split('.')
    if len(parts) != 3:
        print("❌ Invalid JWT format (Must contain 3 parts: header.payload.signature)")
        sys.exit(1)

    header = json.loads(b64_decode(parts[0]))
    payload = json.loads(b64_decode(parts[1]))

    print("\n🔍 JWT Header:", json.dumps(header, indent=2))
    print("🔍 JWT Payload:", json.dumps(payload, indent=2))
    print("\n🛡️ Security Analysis:")

    # 1. Algorithm check
    alg = header.get("alg", "").upper()
    if alg == "NONE":
        print("❌ CRITICAL: 'alg: none' vulnerability detected!")
    elif alg.startswith("HS"):
        print("⚠️ WARNING: Symmetric HMAC algorithm (HS256/384/512) used. For distributed microservices, asymmetric RS256 or EdDSA is strongly recommended.")
    else:
        print(f"✅ Algorithm is asymmetric ({alg}).")

    # 2. Expiration check
    exp = payload.get("exp")
    if not exp:
        print("❌ CRITICAL: Missing 'exp' (expiration) claim!")
    else:
        ttl = exp - int(time.time())
        if ttl <= 0:
            print("⚠️ Token is already EXPIRED.")
        elif ttl > 900:  # > 15 minutes
            print(f"⚠️ WARNING: Access token TTL is {ttl} seconds ({ttl//60} mins). Best practice is <= 15 minutes for access tokens.")
        else:
            print(f"✅ Access token TTL is safe ({ttl} seconds remaining).")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: validate-jwt-security.py <jwt_string>")
        sys.exit(1)
    inspect_jwt(sys.argv[1])
