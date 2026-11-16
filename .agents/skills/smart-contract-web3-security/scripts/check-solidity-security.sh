#!/usr/bin/env bash
# Quick audit checklist for Solidity Smart Contracts

echo "🛡️ Web3 & Smart Contract Security Audit:"
echo "---------------------------------------------------------"
echo "1. [ ] Apakah fungsi transfer nilai eksternal mengikuti Checks-Effects-Interactions (CEI)?"
echo "2. [ ] Apakah modifier nonReentrant diterapkan pada external/public state-modifying functions?"
echo "3. [ ] Apakah otorisasi menggunakan msg.sender (bukan tx.origin)?"
echo "4. [ ] Apakah oracle harga dilindungi dari flash loan manipulation (Chainlink / TWAP)?"
echo "5. [ ] Apakah custom errors digunakan sebagai pengganti require string?"
echo "---------------------------------------------------------"
echo "Status: Web3 security checklist ready."
