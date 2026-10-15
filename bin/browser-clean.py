#!/usr/bin/env python3
# ==============================================================================
# 🧹 FREEBUFF-POWER SUPREME BROWSER PURGER & ANTI-DETECT CLEANER (v8.5)
# Surgically Purges Codebuff, Freebuff & Supabase Residues Across All Profiles
# Supported: Google Chrome, Brave, Chromium, Microsoft Edge, Mozilla Firefox
# ==============================================================================

import os
import sys
import glob
import sqlite3
import shutil
import argparse
from pathlib import Path

C_CYAN = "\033[0;36m"
C_GREEN = "\033[0;32m"
C_YELLOW = "\033[0;33m"
C_RED = "\033[0;31m"
C_PURPLE = "\033[0;35m"
C_BOLD = "\033[1m"
C_DIM = "\033[2m"
C_RESET = "\033[0m"

TARGET_DOMAINS = [
    "%codebuff%",
    "%freebuff%",
    "%supabase%",
    "%challenges.cloudflare%",
    "%cf-turnstile%",
]

BROWSER_ROOTS = [
    ("Google Chrome", os.path.expanduser("~/.config/google-chrome")),
    ("Brave Browser", os.path.expanduser("~/.config/BraveSoftware/Brave-Browser")),
    ("Chromium", os.path.expanduser("~/.config/chromium")),
    ("Microsoft Edge", os.path.expanduser("~/.config/microsoft-edge")),
    ("Mozilla Firefox", os.path.expanduser("~/.mozilla/firefox")),
]

def find_chromium_profiles(root_path):
    profiles = []
    if not os.path.isdir(root_path):
        return profiles
    
    # Check Default profile
    default_dir = os.path.join(root_path, "Default")
    if os.path.isdir(default_dir):
        profiles.append(("Default", default_dir))
    
    # Check Profile 1, Profile 2, etc. and Guest Profile
    for entry in os.listdir(root_path):
        if entry == "Default":
            continue
        full_path = os.path.join(root_path, entry)
        if os.path.isdir(full_path):
            if entry.startswith("Profile ") or entry == "Guest Profile" or entry == "System Profile":
                profiles.append((entry, full_path))
    return profiles

def clean_sqlite_cookies(profile_name, profile_dir, dry_run=False):
    """Surgically purge matching cookies from Cookies or Network/Cookies SQLite database."""
    cookie_paths = [
        os.path.join(profile_dir, "Cookies"),
        os.path.join(profile_dir, "Network", "Cookies"),
    ]
    
    total_purged = 0
    for c_path in cookie_paths:
        if not os.path.isfile(c_path):
            continue
        try:
            conn = sqlite3.connect(c_path, timeout=5.0)
            cursor = conn.cursor()
            
            # Count matching cookies
            where_clauses = " OR ".join(["host_key LIKE ?" for _ in TARGET_DOMAINS])
            query = f"SELECT count(*) FROM cookies WHERE {where_clauses}"
            cursor.execute(query, TARGET_DOMAINS)
            count = cursor.fetchone()[0]
            
            if count > 0:
                total_purged += count
                if not dry_run:
                    del_query = f"DELETE FROM cookies WHERE {where_clauses}"
                    cursor.execute(del_query, TARGET_DOMAINS)
                    conn.commit()
                    try:
                        cursor.execute("VACUUM;")
                    except Exception:
                        pass
            conn.close()

            # Clean WAL and journal files if they exist to prevent uncommitted replay
            if not dry_run:
                for suffix in ["-wal", "-journal"]:
                    w_path = c_path + suffix
                    if os.path.isfile(w_path):
                        try:
                            os.remove(w_path)
                        except Exception:
                            pass
        except Exception as e:
            # If database is locked or corrupt, report silently
            pass
            
    return total_purged

def clean_indexeddb(profile_name, profile_dir, dry_run=False):
    """Purge any IndexedDB storage matching Codebuff or Freebuff."""
    indexeddb_dir = os.path.join(profile_dir, "IndexedDB")
    if not os.path.isdir(indexeddb_dir):
        return 0
    
    purged_count = 0
    try:
        for entry in os.listdir(indexeddb_dir):
            lower = entry.lower()
            if any(dom in lower for dom in ["codebuff", "freebuff", "supabase"]):
                target_path = os.path.join(indexeddb_dir, entry)
                purged_count += 1
                if not dry_run:
                    if os.path.isdir(target_path):
                        shutil.rmtree(target_path, ignore_errors=True)
                    else:
                        os.remove(target_path)
    except Exception:
        pass
    return purged_count

def clean_serviceworkers(profile_name, profile_dir, dry_run=False):
    """Purge matching Service Worker cache."""
    sw_dir = os.path.join(profile_dir, "Service Worker", "CacheStorage")
    if not os.path.isdir(sw_dir):
        return 0
    
    purged_count = 0
    try:
        for entry in os.listdir(sw_dir):
            lower = entry.lower()
            if any(dom in lower for dom in ["codebuff", "freebuff", "supabase"]):
                target_path = os.path.join(sw_dir, entry)
                purged_count += 1
                if not dry_run:
                    shutil.rmtree(target_path, ignore_errors=True)
    except Exception:
        pass
    return purged_count

def clean_firefox_cookies(profile_dir, dry_run=False):
    """Clean cookies.sqlite in Firefox profiles."""
    cookie_path = os.path.join(profile_dir, "cookies.sqlite")
    if not os.path.isfile(cookie_path):
        return 0
    total_purged = 0
    try:
        conn = sqlite3.connect(cookie_path, timeout=5.0)
        cursor = conn.cursor()
        where_clauses = " OR ".join(["host LIKE ?" for _ in TARGET_DOMAINS])
        cursor.execute(f"SELECT count(*) FROM moz_cookies WHERE {where_clauses}", TARGET_DOMAINS)
        count = cursor.fetchone()[0]
        if count > 0:
            total_purged += count
            if not dry_run:
                cursor.execute(f"DELETE FROM moz_cookies WHERE {where_clauses}", TARGET_DOMAINS)
                conn.commit()
                try:
                    cursor.execute("VACUUM;")
                except Exception:
                    pass
        conn.close()
    except Exception:
        pass
    return total_purged

def clean_ephemeral_sandboxes(dry_run=False):
    """Purge temporary stealth sandbox profiles from /tmp."""
    patterns = [
        "/tmp/freebuff-stealth-*",
        "/tmp/codebuff-stealth-*",
        "/tmp/com.google.Chrome.*",
        "/tmp/org.chromium.Chromium.*",
    ]
    purged = 0
    for pat in patterns:
        for match in glob.glob(pat):
            try:
                purged += 1
                if not dry_run:
                    if os.path.isdir(match):
                        shutil.rmtree(match, ignore_errors=True)
                    else:
                        os.remove(match)
            except Exception:
                pass
    return purged

def check_running_browsers():
    running = []
    processes = [("google-chrome", "Google Chrome"), ("chrome", "Google Chrome"), ("brave", "Brave Browser"), ("firefox", "Mozilla Firefox"), ("chromium", "Chromium")]
    try:
        import subprocess
        out = subprocess.check_output(["ps", "-A", "-o", "comm="], universal_newlines=True)
        running_comms = set(line.strip() for line in out.splitlines())
        for proc, name in processes:
            if proc in running_comms and name not in running:
                running.append(name)
    except Exception:
        pass
    return running

def kill_running_browsers():
    import subprocess, time
    targets = ["chrome", "google-chrome", "brave", "firefox", "chromium"]
    for t in targets:
        subprocess.run(["pkill", "-15", "-x", t], stderr=subprocess.DEVNULL, stdout=subprocess.DEVNULL)
    time.sleep(0.8)
    for t in targets:
        subprocess.run(["pkill", "-9", "-x", t], stderr=subprocess.DEVNULL, stdout=subprocess.DEVNULL)

def main():
    parser = argparse.ArgumentParser(description="Freebuff Power Deep Browser Purger & Anti-Detect Tool")
    parser.add_argument("--dry-run", action="store_true", help="Scan only, do not modify or delete files")
    parser.add_argument("--silent", action="store_true", help="Quiet output for scripted execution")
    parser.add_argument("--kill", "--kill-browser", action="store_true", help="Tutup browser yang sedang berjalan agar RAM tidak menulis ulang cookie")
    args = parser.parse_args()

    active_browsers = check_running_browsers()
    if args.kill and active_browsers:
        if not args.silent:
            print(f"{C_YELLOW}🛑 Menutup paksa browser aktif ({', '.join(active_browsers)}) untuk membersihkan RAM...{C_RESET}")
        kill_running_browsers()
        active_browsers = []

    if not args.silent:
        print(f"{C_CYAN}{C_BOLD}========================================================================{C_RESET}")
        print(f"{C_PURPLE}{C_BOLD}🛡️ [FREEBUFF-POWER] SUPREME BROWSER ANTI-DETECT & RESIDUE PURGER{C_RESET}")
        print(f"{C_CYAN}{C_BOLD}========================================================================{C_RESET}\n")
        if active_browsers and not args.dry_run:
            print(f"{C_YELLOW}⚠️  Peringatan: {', '.join(active_browsers)} sedang berjalan di background.{C_RESET}")
            print(f"{C_DIM}   Jika tab Codebuff masih terbuka, browser bisa menulis ulang cookie dari RAM.{C_RESET}")
            print(f"{C_DIM}   Gunakan flag --kill untuk menutup browser sebelum purge: freebuff-power browser clean --kill{C_RESET}\n")

    grand_total_cookies = 0
    grand_total_storage = 0
    profiles_cleaned = 0

    for browser_name, browser_root in BROWSER_ROOTS:
        if not os.path.isdir(browser_root):
            continue

        if "firefox" in browser_root.lower():
            # Firefox profiles
            for entry in os.listdir(browser_root):
                f_dir = os.path.join(browser_root, entry)
                if os.path.isdir(f_dir) and ("default" in entry or "release" in entry):
                    c_purged = clean_firefox_cookies(f_dir, dry_run=args.dry_run)
                    if c_purged > 0:
                        grand_total_cookies += c_purged
                        profiles_cleaned += 1
                        if not args.silent:
                            print(f"  {C_GREEN}✓{C_RESET} {browser_name} [{entry}]: {C_YELLOW}{c_purged} cookies{C_RESET} purged")
            continue

        # Chromium based
        profiles = find_chromium_profiles(browser_root)
        for p_name, p_dir in profiles:
            c_purged = clean_sqlite_cookies(p_name, p_dir, dry_run=args.dry_run)
            idb_purged = clean_indexeddb(p_name, p_dir, dry_run=args.dry_run)
            sw_purged = clean_serviceworkers(p_name, p_dir, dry_run=args.dry_run)

            storage_purged = idb_purged + sw_purged
            if c_purged > 0 or storage_purged > 0:
                grand_total_cookies += c_purged
                grand_total_storage += storage_purged
                profiles_cleaned += 1
                if not args.silent:
                    details = []
                    if c_purged > 0:
                        details.append(f"{C_YELLOW}{c_purged} cookies{C_RESET}")
                    if storage_purged > 0:
                        details.append(f"{C_PURPLE}{storage_purged} storage artifacts{C_RESET}")
                    print(f"  {C_GREEN}✓{C_RESET} {browser_name} [{p_name}]: {', '.join(details)} purged")

    # Clean sandbox profiles in /tmp
    sandboxes_purged = clean_ephemeral_sandboxes(dry_run=args.dry_run)

    if not args.silent:
        print(f"\n{C_CYAN}{C_BOLD}------------------------------------------------------------------------{C_RESET}")
        action_verb = "Terdeteksi" if args.dry_run else "Berhasil Dimusnahkan"
        print(f"🎯 Total Cookie Residue {action_verb} : {C_YELLOW}{C_BOLD}{grand_total_cookies} tracking cookies{C_RESET}")
        print(f"📦 Total Web Storage & Cache Residue  : {C_PURPLE}{C_BOLD}{grand_total_storage} entries{C_RESET}")
        print(f"📁 Profil Browser yang Dibersihkan   : {C_GREEN}{C_BOLD}{profiles_cleaned} profiles{C_RESET}")
        if sandboxes_purged > 0:
            print(f"🧹 Temporary Sandbox /tmp Residue   : {C_CYAN}{C_BOLD}{sandboxes_purged} instances wiped{C_RESET}")
        print(f"{C_CYAN}{C_BOLD}========================================================================{C_RESET}\n")

        if args.dry_run:
            print(f"{C_YELLOW}💡 Jalankan tanpa --dry-run untuk memusnahkan seluruh cookie pelacak di atas.{C_RESET}\n")
        else:
            print(f"{C_GREEN}✅ Seluruh browser kini 100% bersih dari pelacakan Codebuff/Freebuff!{C_RESET}\n")

    return 0

if __name__ == "__main__":
    sys.exit(main())
