#!/usr/bin/env python3
# ==============================================================================
# 🧹 FREEBUFF-POWER SUPREME BROWSER PURGER & ANTI-DETECT CLEANER (v10.0)
# Forensic Disinfectant for Codebuff, Freebuff, PostHog, Supabase Residues
# Supported: Google Chrome, Brave, Chromium, Microsoft Edge, Mozilla Firefox
# ==============================================================================

import os
import sys
import glob
import json
import sqlite3
import shutil
import argparse
import subprocess
import time
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
    "%posthog%",
]

TARGET_BYTES = [
    b"codebuff",
    b"freebuff",
    b"supabase",
    b"posthog",
    b"01a19291-267b-7e4d-9a46-743dd7a82d2e",
]

TARGET_STRINGS = [
    "codebuff",
    "freebuff",
    "supabase",
    "posthog",
    "01a19291-267b-7e4d-9a46-743dd7a82d2e",
]

BROWSER_ROOTS = [
    ("Google Chrome", os.path.expanduser("~/.config/google-chrome")),
    ("Brave Browser", os.path.expanduser("~/.config/BraveSoftware/Brave-Browser")),
    ("Chromium", os.path.expanduser("~/.config/chromium")),
    ("Microsoft Edge", os.path.expanduser("~/.config/microsoft-edge")),
    ("Mozilla Firefox", os.path.expanduser("~/.mozilla/firefox")),
]

def check_running_browsers():
    """Returns list of human-readable names of currently running browser processes."""
    running = []
    processes = [
        ("google-chrome", "Google Chrome"),
        ("google-chrome-stable", "Google Chrome"),
        ("chrome", "Google Chrome"),
        ("brave", "Brave Browser"),
        ("firefox", "Mozilla Firefox"),
        ("chromium", "Chromium"),
        ("msedge", "Microsoft Edge"),
    ]
    try:
        out = subprocess.check_output(["ps", "-A", "-o", "comm="], universal_newlines=True)
        running_comms = set(line.strip() for line in out.splitlines())
        for proc, name in processes:
            if proc in running_comms and name not in running:
                running.append(name)
    except Exception:
        pass
    return running

def kill_running_browsers():
    """Guarantees all browser processes are completely killed to prevent RAM rewrite to disk."""
    targets = ["chrome", "google-chrome", "google-chrome-stable", "brave", "firefox", "chromium", "msedge"]
    for t in targets:
        subprocess.run(["pkill", "-15", "-x", t], stderr=subprocess.DEVNULL, stdout=subprocess.DEVNULL)
        subprocess.run(["pkill", "-15", "-f", t], stderr=subprocess.DEVNULL, stdout=subprocess.DEVNULL)
    time.sleep(1.0)
    for t in targets:
        subprocess.run(["pkill", "-9", "-x", t], stderr=subprocess.DEVNULL, stdout=subprocess.DEVNULL)
        subprocess.run(["pkill", "-9", "-f", t], stderr=subprocess.DEVNULL, stdout=subprocess.DEVNULL)
    time.sleep(0.5)

def find_chromium_profiles(root_path):
    """Enumerates all Chromium profile folders under a given root."""
    profiles = []
    if not os.path.isdir(root_path):
        return profiles
    default_dir = os.path.join(root_path, "Default")
    if os.path.isdir(default_dir):
        profiles.append(("Default", default_dir))
    for entry in os.listdir(root_path):
        if entry == "Default":
            continue
        full_path = os.path.join(root_path, entry)
        if os.path.isdir(full_path):
            if entry.startswith("Profile ") or entry in ("Guest Profile", "System Profile"):
                profiles.append((entry, full_path))
    return profiles

def clean_sqlite_cookies(profile_name, profile_dir, dry_run=False):
    """Purges matching cookies from Cookies and Network/Cookies SQLite database."""
    cookie_paths = [
        os.path.join(profile_dir, "Cookies"),
        os.path.join(profile_dir, "Network", "Cookies"),
    ]
    total_purged = 0
    for c_path in cookie_paths:
        if not os.path.isfile(c_path):
            continue
        try:
            conn = sqlite3.connect(c_path, timeout=0.5)
            cursor = conn.cursor()
            where_clauses = " OR ".join(["host_key LIKE ?" for _ in TARGET_DOMAINS])
            cursor.execute(f"SELECT count(*) FROM cookies WHERE {where_clauses}", TARGET_DOMAINS)
            count = cursor.fetchone()[0]
            if count > 0:
                total_purged += count
                if not dry_run:
                    cursor.execute(f"DELETE FROM cookies WHERE {where_clauses}", TARGET_DOMAINS)
                    conn.commit()
                    try:
                        cursor.execute("VACUUM;")
                    except Exception:
                        pass
            conn.close()
            if not dry_run and count > 0:
                for suffix in ["-wal", "-journal"]:
                    w_path = c_path + suffix
                    if os.path.isfile(w_path):
                        try:
                            os.remove(w_path)
                        except Exception:
                            pass
        except Exception:
            pass
    return total_purged

def clean_local_storage(profile_name, profile_dir, dry_run=False):
    """
    Surgically purges Chromium LevelDB Local Storage containing Freebuff, PostHog, or Supabase.
    PostHog stores persistent device ID ($device_id) here which causes ban linkage!
    """
    leveldb_dir = os.path.join(profile_dir, "Local Storage", "leveldb")
    if not os.path.isdir(leveldb_dir):
        return 0
    found_residue = False
    try:
        for fname in os.listdir(leveldb_dir):
            fpath = os.path.join(leveldb_dir, fname)
            if not os.path.isfile(fpath):
                continue
            try:
                with open(fpath, "rb") as fh:
                    raw = fh.read()
                    if any(target in raw for target in TARGET_BYTES):
                        found_residue = True
                        break
            except Exception:
                pass
    except Exception:
        pass

    if found_residue:
        if not dry_run:
            try:
                shutil.rmtree(leveldb_dir, ignore_errors=True)
                # Also remove associated CURRENT and LOG files in Local Storage root
                ls_root = os.path.join(profile_dir, "Local Storage")
                for item in os.listdir(ls_root):
                    if item.startswith("LOG") or item.startswith("CURRENT"):
                        try:
                            os.remove(os.path.join(ls_root, item))
                        except Exception:
                            pass
            except Exception:
                pass
        return 1
    return 0

def clean_session_storage(profile_name, profile_dir, dry_run=False):
    """Purges Session Storage LevelDB containing tracking tokens."""
    ss_dir = os.path.join(profile_dir, "Session Storage")
    if not os.path.isdir(ss_dir):
        return 0
    found_residue = False
    try:
        for fname in os.listdir(ss_dir):
            fpath = os.path.join(ss_dir, fname)
            if not os.path.isfile(fpath):
                continue
            try:
                with open(fpath, "rb") as fh:
                    raw = fh.read()
                    if any(target in raw for target in TARGET_BYTES):
                        found_residue = True
                        break
            except Exception:
                pass
    except Exception:
        pass

    if found_residue:
        if not dry_run:
            shutil.rmtree(ss_dir, ignore_errors=True)
        return 1
    return 0

def clean_saved_sessions(profile_name, profile_dir, dry_run=False):
    """
    Purges Tabs_* and Session_* restore files in Sessions/ that reference Freebuff.
    Prevents Chrome from auto-restoring freebuff.com/login?error=device_linked_to_banned_account!
    """
    sessions_dir = os.path.join(profile_dir, "Sessions")
    if not os.path.isdir(sessions_dir):
        return 0
    purged_count = 0
    try:
        for fname in os.listdir(sessions_dir):
            fpath = os.path.join(sessions_dir, fname)
            if not os.path.isfile(fpath):
                continue
            try:
                with open(fpath, "rb") as fh:
                    raw = fh.read()
                    if b"freebuff" in raw or b"codebuff" in raw:
                        purged_count += 1
                        if not dry_run:
                            os.remove(fpath)
            except Exception:
                pass
    except Exception:
        pass
    return purged_count

def clean_preferences(profile_name, profile_dir, dry_run=False):
    """
    Sanitizes Chrome Preferences JSON: removes OAuth login detection, media/site engagement scores,
    and all cookie controls or origin settings referencing target domains recursively.
    """
    pref_path = os.path.join(profile_dir, "Preferences")
    if not os.path.isfile(pref_path):
        return 0
    try:
        with open(pref_path, "r", encoding="utf-8", errors="ignore") as fh:
            data = json.load(fh)
    except Exception:
        return 0

    modified = False

    def sanitize(node):
        nonlocal modified
        if isinstance(node, dict):
            del_keys = [k for k in node if any(d in k.lower() for d in ["freebuff", "codebuff"])]
            if del_keys:
                for k in del_keys:
                    del node[k]
                modified = True
            for v in list(node.values()):
                sanitize(v)
        elif isinstance(node, list):
            i = len(node) - 1
            while i >= 0:
                item = node[i]
                if isinstance(item, (dict, list)):
                    sanitize(item)
                elif isinstance(item, str) and any(d in item.lower() for d in ["freebuff", "codebuff"]):
                    node.pop(i)
                    modified = True
                i -= 1

    if "zerosuggest" in data:
        del data["zerosuggest"]
        modified = True

    sanitize(data)

    if modified:
        if not dry_run:
            try:
                with open(pref_path, "w", encoding="utf-8") as fh:
                    json.dump(data, fh, indent=2)
            except Exception:
                pass
        return 1
    return 0

def clean_network_persistent_state(profile_name, profile_dir, dry_run=False):
    """
    Purges cached TLS session resumption tickets & HTTP/3 QUIC states from Network Persistent State.
    """
    nps_path = os.path.join(profile_dir, "Network Persistent State")
    if not os.path.isfile(nps_path):
        return 0
    try:
        with open(nps_path, "r", encoding="utf-8", errors="ignore") as fh:
            data = json.load(fh)
    except Exception:
        return 0

    modified = False
    servers = data.get("net", {}).get("http_server_properties", {}).get("servers", [])
    if isinstance(servers, list):
        filtered_servers = [
            s for s in servers
            if not any(d in str(s.get("server", "")).lower() for d in ["freebuff", "codebuff"])
        ]
        if len(filtered_servers) != len(servers):
            data["net"]["http_server_properties"]["servers"] = filtered_servers
            modified = True

    alt_svc = data.get("net", {}).get("http_server_properties", {}).get("broken_alternative_services", [])
    if isinstance(alt_svc, list):
        filtered_alt = [
            a for a in alt_svc
            if not any(d in str(a.get("host", "")).lower() for d in ["freebuff", "codebuff"])
        ]
        if len(filtered_alt) != len(alt_svc):
            data["net"]["http_server_properties"]["broken_alternative_services"] = filtered_alt
            modified = True

    if modified:
        if not dry_run:
            try:
                with open(nps_path, "w", encoding="utf-8") as fh:
                    json.dump(data, fh, indent=2)
            except Exception:
                pass
        return 1
    return 0

def clean_dips(profile_name, profile_dir, dry_run=False):
    """Purges bounce tracking records from DIPS database."""
    dips_path = os.path.join(profile_dir, "DIPS")
    if not os.path.isfile(dips_path):
        return 0
    total = 0
    try:
        conn = sqlite3.connect(dips_path, timeout=0.5)
        cursor = conn.cursor()
        cursor.execute("SELECT count(*) FROM bounces WHERE site LIKE '%freebuff%' OR site LIKE '%codebuff%' OR site LIKE '%supabase%'")
        count = cursor.fetchone()[0]
        if count > 0:
            total += count
            if not dry_run:
                cursor.execute("DELETE FROM bounces WHERE site LIKE '%freebuff%' OR site LIKE '%codebuff%' OR site LIKE '%supabase%'")
                try:
                    cursor.execute("DELETE FROM popups WHERE site LIKE '%freebuff%' OR site LIKE '%codebuff%'")
                except Exception:
                    pass
                conn.commit()
                try:
                    cursor.execute("VACUUM;")
                except Exception:
                    pass
        conn.close()
        if not dry_run and count > 0:
            for suffix in ["-wal", "-journal"]:
                w = dips_path + suffix
                if os.path.isfile(w):
                    try:
                        os.remove(w)
                    except Exception:
                        pass
    except Exception:
        pass
    return total

def clean_history(profile_name, profile_dir, dry_run=False):
    """Purges Freebuff and Codebuff navigation records from Chrome History SQLite database."""
    hist_path = os.path.join(profile_dir, "History")
    if not os.path.isfile(hist_path):
        return 0
    total = 0
    try:
        conn = sqlite3.connect(hist_path, timeout=0.5)
        cursor = conn.cursor()
        queries = [
            "DELETE FROM urls WHERE url LIKE '%freebuff%' OR url LIKE '%codebuff%' OR title LIKE '%freebuff%' OR title LIKE '%codebuff%'",
            "DELETE FROM visits WHERE url_id NOT IN (SELECT id FROM urls)",
            "DELETE FROM visits WHERE instr(external_referrer_url, 'freebuff') > 0 OR instr(external_referrer_url, 'codebuff') > 0",
            "DELETE FROM visited_links WHERE top_level_url LIKE '%freebuff%' OR top_level_url LIKE '%codebuff%' OR frame_url LIKE '%freebuff%' OR frame_url LIKE '%codebuff%'",
            "DELETE FROM clusters_and_visits WHERE instr(url_for_deduping, 'freebuff') > 0 OR instr(normalized_url, 'freebuff') > 0 OR instr(url_for_display, 'freebuff') > 0 OR instr(url_for_deduping, 'codebuff') > 0 OR instr(normalized_url, 'codebuff') > 0 OR instr(url_for_display, 'codebuff') > 0",
            "DELETE FROM segments WHERE name LIKE '%freebuff%' OR name LIKE '%codebuff%'",
            "DELETE FROM keyword_search_terms WHERE instr(term, 'freebuff') > 0 OR instr(normalized_term, 'freebuff') > 0 OR instr(term, 'codebuff') > 0 OR instr(normalized_term, 'codebuff') > 0",
            "DELETE FROM content_annotations WHERE instr(search_normalized_url, 'freebuff') > 0 OR instr(search_terms, 'freebuff') > 0 OR instr(search_normalized_url, 'codebuff') > 0 OR instr(search_terms, 'codebuff') > 0",
            "DELETE FROM downloads WHERE referrer LIKE '%freebuff%' OR tab_url LIKE '%freebuff%' OR tab_referrer_url LIKE '%freebuff%' OR referrer LIKE '%codebuff%' OR tab_url LIKE '%codebuff%'",
            "DELETE FROM downloads_url_chains WHERE url LIKE '%freebuff%' OR url LIKE '%codebuff%'",
        ]
        for q in queries:
            try:
                cursor.execute(q)
                if cursor.rowcount > 0:
                    total += cursor.rowcount
            except Exception:
                pass

        if not dry_run and total > 0:
            conn.commit()
            try:
                cursor.execute("VACUUM;")
            except Exception:
                pass
        conn.close()
        if not dry_run and total > 0:
            for suffix in ["-wal", "-journal"]:
                w = hist_path + suffix
                if os.path.isfile(w):
                    try:
                        os.remove(w)
                    except Exception:
                        pass
    except Exception:
        pass
    return total

def clean_shortcuts_and_predictors(profile_name, profile_dir, dry_run=False):
    """Purges autocomplete URL predictors, omnibox shortcuts, favicons, and prefetch databases."""
    purged = 0
    # 1. Shortcuts
    sc_path = os.path.join(profile_dir, "Shortcuts")
    if os.path.isfile(sc_path):
        try:
            conn = sqlite3.connect(sc_path, timeout=0.5)
            c = conn.cursor()
            c.execute("DELETE FROM omni_box_shortcuts WHERE url LIKE '%freebuff%' OR url LIKE '%codebuff%' OR fill_into_edit LIKE '%freebuff%' OR fill_into_edit LIKE '%codebuff%' OR text LIKE '%freebuff%' OR text LIKE '%codebuff%'")
            if not dry_run:
                conn.commit()
                try:
                    c.execute("VACUUM;")
                except Exception:
                    pass
            purged += c.rowcount if c.rowcount > 0 else 0
            conn.close()
        except Exception:
            pass

    # 2. Network Action Predictor
    nap_path = os.path.join(profile_dir, "Network Action Predictor")
    if os.path.isfile(nap_path):
        try:
            conn = sqlite3.connect(nap_path, timeout=0.5)
            c = conn.cursor()
            for tbl, col in [
                ("network_action_predictor", "user_text"),
                ("network_action_predictor", "url"),
                ("resource_prefetch_predictor_host_redirect", "key"),
                ("resource_prefetch_predictor_host_redirect", "proto"),
                ("resource_prefetch_predictor_origin", "key"),
                ("resource_prefetch_predictor_origin", "proto"),
                ("lcp_critical_path_predictor", "key"),
                ("lcp_critical_path_predictor", "proto"),
                ("lcp_critical_path_predictor_initiator_origin", "key"),
                ("lcp_critical_path_predictor_initiator_origin", "proto"),
            ]:
                try:
                    c.execute(f"DELETE FROM {tbl} WHERE {col} LIKE '%freebuff%' OR {col} LIKE '%codebuff%' OR instr({col}, 'freebuff') > 0 OR instr({col}, 'codebuff') > 0")
                    if c.rowcount > 0:
                        purged += c.rowcount
                except Exception:
                    pass
            if not dry_run:
                conn.commit()
                try:
                    c.execute("VACUUM;")
                except Exception:
                    pass
            conn.close()
        except Exception:
            pass

    # 3. Favicons
    fav_path = os.path.join(profile_dir, "Favicons")
    if os.path.isfile(fav_path):
        try:
            conn = sqlite3.connect(fav_path, timeout=0.5)
            c = conn.cursor()
            c.execute("DELETE FROM icon_mapping WHERE page_url LIKE '%freebuff%' OR page_url LIKE '%codebuff%'")
            if c.rowcount > 0:
                purged += c.rowcount
            c.execute("DELETE FROM favicons WHERE url LIKE '%freebuff%' OR url LIKE '%codebuff%'")
            if c.rowcount > 0:
                purged += c.rowcount
            if not dry_run:
                conn.commit()
                try:
                    c.execute("VACUUM;")
                except Exception:
                    pass
            conn.close()
        except Exception:
            pass

    # 4. QuotaManager
    qm_path = os.path.join(profile_dir, "WebStorage", "QuotaManager")
    if os.path.isfile(qm_path):
        try:
            conn = sqlite3.connect(qm_path, timeout=0.5)
            c = conn.cursor()
            c.execute("DELETE FROM buckets WHERE host LIKE '%freebuff%' OR host LIKE '%codebuff%' OR storage_key LIKE '%freebuff%' OR storage_key LIKE '%codebuff%'")
            if c.rowcount > 0:
                purged += c.rowcount
            if not dry_run:
                conn.commit()
                try:
                    c.execute("VACUUM;")
                except Exception:
                    pass
            conn.close()
        except Exception:
            pass

    return purged

def clean_indexeddb(profile_name, profile_dir, dry_run=False):
    """Purges IndexedDB directories matching Codebuff or Freebuff."""
    indexeddb_dir = os.path.join(profile_dir, "IndexedDB")
    if not os.path.isdir(indexeddb_dir):
        return 0
    purged = 0
    try:
        for entry in os.listdir(indexeddb_dir):
            lower = entry.lower()
            if any(dom in lower for dom in ["codebuff", "freebuff", "supabase"]):
                target_path = os.path.join(indexeddb_dir, entry)
                purged += 1
                if not dry_run:
                    if os.path.isdir(target_path):
                        shutil.rmtree(target_path, ignore_errors=True)
                    else:
                        os.remove(target_path)
    except Exception:
        pass
    return purged

def clean_serviceworkers(profile_name, profile_dir, dry_run=False):
    """Purges Service Worker cache storage."""
    sw_dir = os.path.join(profile_dir, "Service Worker", "CacheStorage")
    if not os.path.isdir(sw_dir):
        return 0
    purged = 0
    try:
        for entry in os.listdir(sw_dir):
            lower = entry.lower()
            if any(dom in lower for dom in ["codebuff", "freebuff", "supabase"]):
                target_path = os.path.join(sw_dir, entry)
                purged += 1
                if not dry_run:
                    shutil.rmtree(target_path, ignore_errors=True)
    except Exception:
        pass
    return purged

def clean_supplementary_sqlite(profile_name, profile_dir, dry_run=False):
    """Purges Top Sites, Reporting and NEL, and Web Data (Autofill)."""
    purged = 0
    # 1. Top Sites
    ts_path = os.path.join(profile_dir, "Top Sites")
    if os.path.isfile(ts_path):
        try:
            conn = sqlite3.connect(ts_path, timeout=0.5)
            c = conn.cursor()
            c.execute("DELETE FROM top_sites WHERE url LIKE '%freebuff%' OR url LIKE '%codebuff%' OR title LIKE '%freebuff%' OR title LIKE '%codebuff%'")
            if c.rowcount > 0:
                purged += c.rowcount
            if not dry_run:
                conn.commit()
                try:
                    c.execute("VACUUM;")
                except Exception:
                    pass
            conn.close()
        except Exception:
            pass

    # 2. Reporting and NEL
    nel_path = os.path.join(profile_dir, "Reporting and NEL")
    if os.path.isfile(nel_path):
        try:
            conn = sqlite3.connect(nel_path, timeout=0.5)
            c = conn.cursor()
            for tbl in ["nel_policies", "reporting_endpoints", "reporting_endpoint_groups"]:
                try:
                    c.execute(f"DELETE FROM {tbl} WHERE origin_host LIKE '%freebuff%' OR origin_host LIKE '%codebuff%'")
                    if c.rowcount > 0:
                        purged += c.rowcount
                except Exception:
                    pass
            if not dry_run:
                conn.commit()
                try:
                    c.execute("VACUUM;")
                except Exception:
                    pass
            conn.close()
        except Exception:
            pass

    # 3. Web Data
    wd_path = os.path.join(profile_dir, "Web Data")
    if os.path.isfile(wd_path):
        try:
            conn = sqlite3.connect(wd_path, timeout=0.5)
            c = conn.cursor()
            c.execute("DELETE FROM autofill WHERE name LIKE '%freebuff%' OR value LIKE '%freebuff%' OR name LIKE '%codebuff%' OR value LIKE '%codebuff%'")
            if c.rowcount > 0:
                purged += c.rowcount
            if not dry_run:
                conn.commit()
                try:
                    c.execute("VACUUM;")
                except Exception:
                    pass
            conn.close()
        except Exception:
            pass

    return purged

def clean_sync_and_file_system(profile_name, profile_dir, dry_run=False):
    """Purges Sync Data LevelDB logs and File System directory."""
    purged = 0
    sync_dir = os.path.join(profile_dir, "Sync Data")
    if os.path.isdir(sync_dir):
        found = False
        try:
            for root, _, files in os.walk(sync_dir):
                for fname in files:
                    fp = os.path.join(root, fname)
                    try:
                        with open(fp, "rb") as fh:
                            if any(target in fh.read() for target in TARGET_BYTES):
                                found = True
                                break
                    except Exception:
                        pass
                if found:
                    break
            if found:
                purged += 1
                if not dry_run:
                    shutil.rmtree(os.path.join(sync_dir, "LevelDB"), ignore_errors=True)
        except Exception:
            pass

    fs_dir = os.path.join(profile_dir, "File System")
    if os.path.isdir(fs_dir):
        found = False
        try:
            for root, _, files in os.walk(fs_dir):
                for fname in files:
                    fp = os.path.join(root, fname)
                    try:
                        with open(fp, "rb") as fh:
                            if any(target in fh.read() for target in TARGET_BYTES):
                                found = True
                                break
                    except Exception:
                        pass
                if found:
                    break
            if found:
                purged += 1
                if not dry_run:
                    shutil.rmtree(fs_dir, ignore_errors=True)
        except Exception:
            pass

    return purged

def clean_firefox_profile(profile_dir, dry_run=False):
    """Deep purges Firefox cookies, history places, storage, and session backups."""
    purged = 0
    # 1. moz_cookies
    c_path = os.path.join(profile_dir, "cookies.sqlite")
    if os.path.isfile(c_path):
        try:
            conn = sqlite3.connect(c_path, timeout=0.5)
            cursor = conn.cursor()
            where_clauses = " OR ".join(["host LIKE ?" for _ in TARGET_DOMAINS])
            cursor.execute(f"SELECT count(*) FROM moz_cookies WHERE {where_clauses}", TARGET_DOMAINS)
            count = cursor.fetchone()[0]
            if count > 0:
                purged += count
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

    # 2. places.sqlite
    p_path = os.path.join(profile_dir, "places.sqlite")
    if os.path.isfile(p_path):
        try:
            conn = sqlite3.connect(p_path, timeout=0.5)
            cursor = conn.cursor()
            cursor.execute("SELECT count(*) FROM moz_places WHERE url LIKE '%freebuff%' OR url LIKE '%codebuff%'")
            count = cursor.fetchone()[0]
            if count > 0:
                purged += count
                if not dry_run:
                    cursor.execute("DELETE FROM moz_places WHERE url LIKE '%freebuff%' OR url LIKE '%codebuff%'")
                    conn.commit()
                    try:
                        cursor.execute("VACUUM;")
                    except Exception:
                        pass
            conn.close()
        except Exception:
            pass

    # 3. storage/default
    storage_dir = os.path.join(profile_dir, "storage", "default")
    if os.path.isdir(storage_dir):
        try:
            for entry in os.listdir(storage_dir):
                if any(dom in entry.lower() for dom in ["codebuff", "freebuff"]):
                    purged += 1
                    if not dry_run:
                        shutil.rmtree(os.path.join(storage_dir, entry), ignore_errors=True)
        except Exception:
            pass

    return purged

def clean_ephemeral_sandboxes(dry_run=False):
    """Purges temporary stealth sandbox profiles from /tmp."""
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

def main():
    parser = argparse.ArgumentParser(description="Freebuff Power Superpower Forensic Disinfectant (v10.0)")
    parser.add_argument("--dry-run", action="store_true", help="Scan only, do not modify or delete files")
    parser.add_argument("--silent", action="store_true", help="Quiet output for scripted execution")
    parser.add_argument("--kill", "--kill-browser", action="store_true", help="Tutup browser yang sedang berjalan agar RAM tidak menulis ulang cookie")
    args = parser.parse_args()

    active_browsers = check_running_browsers()
    if args.kill and active_browsers:
        if not args.silent:
            print(f"{C_YELLOW}🛑 Menutup paksa browser aktif ({', '.join(active_browsers)}) untuk membersihkan RAM...{C_RESET}")
        kill_running_browsers()
        active_browsers = check_running_browsers()

    if not args.silent:
        print(f"{C_CYAN}{C_BOLD}========================================================================{C_RESET}")
        print(f"{C_PURPLE}{C_BOLD}🛡️ [FREEBUFF-POWER] SUPREME BROWSER FORENSIC DISINFECTANT (v10.0){C_RESET}")
        print(f"{C_CYAN}{C_BOLD}========================================================================{C_RESET}\n")
        if active_browsers and not args.dry_run:
            print(f"{C_YELLOW}⚠️  Peringatan: {', '.join(active_browsers)} masih terdeteksi di background.{C_RESET}")
            print(f"{C_DIM}   Gunakan flag --kill untuk menutup browser sebelum purge: freebuff-power browser clean --kill{C_RESET}\n")

    grand_total_cookies = 0
    grand_total_leveldb = 0
    grand_total_sessions = 0
    grand_total_dips = 0
    grand_total_history = 0
    grand_total_prefs = 0
    grand_total_network = 0
    grand_total_storage = 0
    profiles_cleaned = 0

    for browser_name, browser_root in BROWSER_ROOTS:
        if not os.path.isdir(browser_root):
            continue

        if "firefox" in browser_root.lower():
            for entry in os.listdir(browser_root):
                f_dir = os.path.join(browser_root, entry)
                if os.path.isdir(f_dir) and ("default" in entry or "release" in entry):
                    ff_purged = clean_firefox_profile(f_dir, dry_run=args.dry_run)
                    if ff_purged > 0:
                        grand_total_cookies += ff_purged
                        profiles_cleaned += 1
                        if not args.silent:
                            print(f"  {C_GREEN}✓{C_RESET} {browser_name} [{entry}]: {C_YELLOW}{ff_purged} artifacts{C_RESET} purged")
            continue

        profiles = find_chromium_profiles(browser_root)
        for p_name, p_dir in profiles:
            c_purged = clean_sqlite_cookies(p_name, p_dir, dry_run=args.dry_run)
            ldb_purged = clean_local_storage(p_name, p_dir, dry_run=args.dry_run)
            ss_purged = clean_session_storage(p_name, p_dir, dry_run=args.dry_run)
            sess_purged = clean_saved_sessions(p_name, p_dir, dry_run=args.dry_run)
            dips_purged = clean_dips(p_name, p_dir, dry_run=args.dry_run)
            hist_purged = clean_history(p_name, p_dir, dry_run=args.dry_run)
            pref_purged = clean_preferences(p_name, p_dir, dry_run=args.dry_run)
            net_purged = clean_network_persistent_state(p_name, p_dir, dry_run=args.dry_run)
            pred_purged = clean_shortcuts_and_predictors(p_name, p_dir, dry_run=args.dry_run)
            supp_purged = clean_supplementary_sqlite(p_name, p_dir, dry_run=args.dry_run)
            idb_purged = clean_indexeddb(p_name, p_dir, dry_run=args.dry_run)
            sw_purged = clean_serviceworkers(p_name, p_dir, dry_run=args.dry_run)
            sync_purged = clean_sync_and_file_system(p_name, p_dir, dry_run=args.dry_run)

            total_profile_artifacts = (
                c_purged + ldb_purged + ss_purged + sess_purged + dips_purged +
                hist_purged + pref_purged + net_purged + pred_purged + supp_purged +
                idb_purged + sw_purged + sync_purged
            )

            if total_profile_artifacts > 0:
                grand_total_cookies += c_purged
                grand_total_leveldb += (ldb_purged + ss_purged)
                grand_total_sessions += sess_purged
                grand_total_dips += dips_purged
                grand_total_history += hist_purged
                grand_total_prefs += pref_purged
                grand_total_network += net_purged
                grand_total_storage += (idb_purged + sw_purged + pred_purged + supp_purged + sync_purged)
                profiles_cleaned += 1

                if not args.silent:
                    details = []
                    if ldb_purged > 0:
                        details.append(f"{C_RED}LevelDB PostHog/LocalStorage Wiped{C_RESET}")
                    if sess_purged > 0:
                        details.append(f"{C_PURPLE}{sess_purged} Saved Tab Restores Deleted{C_RESET}")
                    if c_purged > 0:
                        details.append(f"{C_YELLOW}{c_purged} Cookies{C_RESET}")
                    if dips_purged > 0:
                        details.append(f"{C_CYAN}{dips_purged} DIPS Bounces{C_RESET}")
                    if hist_purged > 0:
                        details.append(f"{C_DIM}{hist_purged} History URLs{C_RESET}")
                    if pref_purged > 0:
                        details.append(f"{C_GREEN}Preferences Sanitized{C_RESET}")
                    if net_purged > 0:
                        details.append(f"{C_CYAN}TLS State Cleared{C_RESET}")
                    print(f"  {C_GREEN}✓{C_RESET} {browser_name} [{p_name}]: {', '.join(details)}")

    sandboxes_purged = clean_ephemeral_sandboxes(dry_run=args.dry_run)

    if not args.silent:
        action_verb = "Terdeteksi" if args.dry_run else "Berhasil Dimusnahkan"
        print(f"\n{C_CYAN}{C_BOLD}------------------------------------------------------------------------{C_RESET}")
        print(f"🎯 Total Cookie Pelacak {action_verb}      : {C_YELLOW}{C_BOLD}{grand_total_cookies}{C_RESET}")
        print(f"🔥 LocalStorage & PostHog Device ID Wiped   : {C_RED}{C_BOLD}{grand_total_leveldb} profiles{C_RESET}")
        print(f"📑 Tab & URL Restore Session Dimusnahkan   : {C_PURPLE}{C_BOLD}{grand_total_sessions} tabs{C_RESET}")
        print(f"🌐 Bounce Tracking (DIPS) & TLS Tickets     : {C_CYAN}{C_BOLD}{grand_total_dips + grand_total_network} records{C_RESET}")
        print(f"📜 Riwayat & History URL Dihapus           : {C_DIM}{C_BOLD}{grand_total_history} entries{C_RESET}")
        print(f"⚙️ Preferences & OAuth Engagement Reset    : {C_GREEN}{C_BOLD}{grand_total_prefs} profiles{C_RESET}")
        print(f"📦 IndexedDB, Cache & Storage Dimusnahkan  : {C_PURPLE}{C_BOLD}{grand_total_storage} entries{C_RESET}")
        print(f"📁 Total Profil Browser yang Disterilisasi : {C_GREEN}{C_BOLD}{profiles_cleaned} profiles{C_RESET}")
        if sandboxes_purged > 0:
            print(f"🧹 Temporary Sandbox /tmp Residue          : {C_CYAN}{C_BOLD}{sandboxes_purged} instances wiped{C_RESET}")
        print(f"{C_CYAN}{C_BOLD}========================================================================{C_RESET}\n")

        if args.dry_run:
            print(f"{C_YELLOW}💡 Jalankan tanpa --dry-run untuk memusnahkan seluruh residu pelacak di atas.{C_RESET}\n")
        else:
            print(f"{C_GREEN}✅ SELURUH BROWSER KINI 100% STERIL DARI PELACAKAN POSTHOG, CODEBUFF & FREEBUFF!{C_RESET}\n")

    return 0

if __name__ == "__main__":
    sys.exit(main())
