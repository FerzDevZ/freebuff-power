#!/usr/bin/env bash
# Quick audit checklist for Python FastAPI codebases

echo "🐍 Python & FastAPI Best Practice Audit:"
echo "---------------------------------------------------------"
echo "1. [ ] Apakah semua database calls menggunakan async/await (asyncpg)?"
echo "2. [ ] Apakah Pydantic v2 schemas digunakan untuk request & response models?"
echo "3. [ ] Apakah lifespan context manager digunakan sebagai pengganti on_event('startup')?"
echo "4. [ ] Apakah type annotations lengkap (mypy --strict passing)?"
echo "---------------------------------------------------------"
echo "Status: Python FastAPI audit checklist completed."
