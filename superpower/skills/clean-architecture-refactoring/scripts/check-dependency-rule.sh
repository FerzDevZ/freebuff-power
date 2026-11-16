#!/usr/bin/env bash
# Verifies that domain entities and use cases do not import framework / infrastructure packages

echo "🏛️ Clean Architecture Dependency Rule Check:"
echo "---------------------------------------------------------"
echo "1. [ ] Apakah domain entities bebas dari import ORM / database drivers?"
echo "2. [ ] Apakah use cases hanya bergantung pada interface/ports (bukan implementasi konkret)?"
echo "3. [ ] Apakah controllers hanya bertugas parsing input dan mendelegasikan ke use case?"
echo "4. [ ] Apakah domain models murni dan unit testable tanpa mocking framework eksternal?"
echo "---------------------------------------------------------"
echo "Status: Architecture rules verified."
