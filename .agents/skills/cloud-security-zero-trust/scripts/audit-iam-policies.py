#!/usr/bin/env python3
"""
IAM Least-Privilege Policy Auditor
Detects wildcard actions ('*') and overly permissive resource blocks in IAM policies.
"""

import sys
import json
from pathlib import Path

def audit_policy(policy_path: Path):
    with open(policy_path, "r", encoding="utf-8") as f:
        policy = json.load(f)

    statements = policy.get("Statement", [])
    violations = []

    for idx, stmt in enumerate(statements, 1):
        effect = stmt.get("Effect", "")
        action = stmt.get("Action", [])
        resource = stmt.get("Resource", [])

        if effect == "Allow":
            if action == "*" or "*" in action:
                violations.append(f"Statement #{idx}: Wildcard Action '*' detected!")
            if resource == "*" or "*" in resource:
                violations.append(f"Statement #{idx}: Wildcard Resource '*' detected!")

    if violations:
        print("❌ IAM Policy Violations Found:")
        for v in violations:
            print(f"  • {v}")
        sys.exit(1)
    else:
        print("✅ IAM Policy adheres to least-privilege standards.")
        sys.exit(0)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: audit-iam-policies.py <policy.json>")
        sys.exit(0)
    audit_policy(Path(sys.argv[1]))
