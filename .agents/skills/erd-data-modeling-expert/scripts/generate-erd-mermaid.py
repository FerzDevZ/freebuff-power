#!/usr/bin/env python3
"""
Simple DDL to Mermaid ERD Diagram generator
Reads a SQL schema file and outputs a Mermaid erDiagram block.
"""

import sys
import re
from pathlib import Path

def parse_sql_to_mermaid(sql_text: str) -> str:
    tables = re.findall(r"CREATE TABLE(?:\s+IF NOT EXISTS)?\s+(\w+)\s*\((.*?)\);", sql_text, re.DOTALL | re.IGNORECASE)
    
    mermaid = ["erDiagram"]
    
    for table_name, body in tables:
        mermaid.append(f"    {table_name.upper()} {{")
        lines = [l.strip() for l in body.split(",") if l.strip()]
        for line in lines:
            if re.match(r"^(PRIMARY KEY|CONSTRAINT|FOREIGN KEY|CREATE)", line, re.IGNORECASE):
                continue
            parts = line.split()
            if len(parts) >= 2:
                col_name = parts[0]
                col_type = parts[1]
                key_type = "PK" if "PRIMARY KEY" in line.upper() else ("FK" if "REFERENCES" in line.upper() else "")
                mermaid.append(f"        {col_type.lower()} {col_name} {key_type}".strip())
        mermaid.append("    }")
        
    return "\n".join(mermaid)

def main():
    if len(sys.argv) < 2:
        print("Usage: generate-erd-mermaid.py <schema.sql>")
        sys.exit(1)
        
    sql_path = Path(sys.argv[1])
    if not sql_path.exists():
        print(f"Error: {sql_path} does not exist.")
        sys.exit(1)
        
    sql_text = sql_path.read_text(encoding="utf-8")
    print("\n```mermaid")
    print(parse_sql_to_mermaid(sql_text))
    print("```\n")

if __name__ == "__main__":
    main()
