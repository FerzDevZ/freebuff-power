#!/usr/bin/env python3
import sys, os, zipfile, json, re, xml.etree.ElementTree as ET

def validate_aia(aia_path):
    print(f"[*] Auditing Kodular AIA: {aia_path}")
    if not os.path.exists(aia_path):
        print(f"[ERROR] File not found: {aia_path}")
        return False

    errors = []
    warnings = []

    try:
        with zipfile.ZipFile(aia_path, "r") as z:
            names = z.namelist()

            # 1. Check project.properties
            prop_file = "youngandroidproject/project.properties"
            if prop_file not in names:
                errors.append(f"Missing required file: {prop_file}")
                return False

            props = z.read(prop_file).decode("utf-8")
            screen_match = re.search(r"screenNames=([^\r\n]+)", props)
            main_match = re.search(r"main=([^\r\n]+)", props)

            if not screen_match:
                errors.append("Missing 'screenNames' entry in project.properties")
                registered_screens = []
            else:
                registered_screens = [s.strip() for s in screen_match.group(1).split(",") if s.strip()]

            if not main_match:
                errors.append("Missing 'main' entry in project.properties")

            print(f"[*] Registered screens ({len(registered_screens)}): {', '.join(registered_screens)}")

            # 2. Check SCM & BKY integrity for each screen
            src_files = [f for f in names if f.startswith("src/") and (f.endswith(".scm") or f.endswith(".bky"))]
            if not src_files:
                errors.append("No source files found in src/")
                return False

            base_dir = os.path.dirname(src_files[0])

            def collect_all_names(component_list):
                found = set()
                for c in component_list:
                    if "$Name" in c:
                        found.add(c["$Name"])
                    if "$Components" in c:
                        found.update(collect_all_names(c["$Components"]))
                return found

            for sname in registered_screens:
                scm_name = f"{base_dir}/{sname}.scm"
                bky_name = f"{base_dir}/{sname}.bky"

                if scm_name not in names:
                    errors.append(f"Missing SCM file for screen: {sname} ({scm_name})")
                    continue
                if bky_name not in names:
                    errors.append(f"Missing BKY file for screen: {sname} ({bky_name})")
                    continue

                # Validate SCM JSON
                scm_raw = z.read(scm_name).decode("utf-8")
                clean_json = scm_raw.replace("#|\n$JSON\n", "").replace("\n|#", "").strip()
                try:
                    scm_data = json.loads(clean_json)
                    comps = scm_data.get("Properties", {}).get("$Components", [])
                    comp_names = collect_all_names(comps)
                except Exception as e:
                    errors.append(f"Invalid JSON in {sname}.scm: {e}")
                    comp_names = set()

                # Validate BKY XML
                bky_raw = z.read(bky_name).decode("utf-8")
                try:
                    ET.fromstring(bky_raw)
                except Exception as e:
                    errors.append(f"Invalid XML / Unescaped entity in {sname}.bky: {e}")

                # Check component reference matching
                instances = re.findall(r'instance_name="([^"]+)"', bky_raw)
                for inst in instances:
                    if inst != sname and inst not in comp_names:
                        errors.append(f"Undefined component reference in {sname}.bky: '{inst}' not in {sname}.scm")

            # 3. Check assets
            assets = [f for f in names if f.startswith("assets/")]
            print(f"[*] Embedded assets ({len(assets)}): {[os.path.basename(a) for a in assets]}")

    except Exception as e:
        errors.append(f"Fatal exception during AIA read: {e}")

    print("\n" + "="*50)
    if errors:
        print(f"[FAIL] {len(errors)} error(s) detected:")
        for err in errors:
            print(f"  ❌ {err}")
        return False
    else:
        print("✅ [SUCCESS] AIA passed 100% Kodular compliance validation!")
        return True

if __name__ == "__main__":
    target = sys.argv[1] if len(sys.argv) > 1 else "/home/firman/Downloads/SportEducation.aia"
    success = validate_aia(target)
    sys.exit(0 if success else 1)
