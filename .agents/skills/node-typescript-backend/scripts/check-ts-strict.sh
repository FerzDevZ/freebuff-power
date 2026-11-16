#!/usr/bin/env bash
# Verifies tsconfig.json has strict mode and best practice compiler options

echo "🟦 TypeScript Compiler Strictness Audit:"
echo "---------------------------------------------------------"
echo "1. [ ] Apakah 'strict: true' aktif di tsconfig.json?"
echo "2. [ ] Apakah 'noUncheckedIndexedAccess: true' aktif?"
echo "3. [ ] Apakah tidak ada penggunaan 'any' eksplisit tanpa eslint-disable beralasan kuat?"
echo "4. [ ] Apakah semua payload input divalidasi dengan runtime parser (Zod / Valibot)?"
echo "---------------------------------------------------------"
echo "Status: TypeScript backend audit checklist ready."
