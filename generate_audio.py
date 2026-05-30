import json, os, glob, subprocess, sys

VOICE_FIL = "fil-PH-BlessicaNeural"
VOICE_ENG = "en-US-JennyNeural"

def generate(text, voice, out_path):
    try:
        cmd = [sys.executable, "-m", "edge_tts",
               "--voice", voice,
               "--text", text,
               "--write-media", out_path]
        subprocess.run(cmd, check=True, capture_output=True)
        kb = os.path.getsize(out_path) / 1024
        print(f"  OK {os.path.basename(out_path)} ({kb:.0f}KB)")
    except Exception as e:
        print(f"  ERROR {out_path}: {e}")

json_files = glob.glob("assets/alamat/**/*.json", recursive=True)
print(f"Nahanap: {len(json_files)} kwento")

for jf in sorted(json_files):
    with open(jf, encoding="utf-8") as f:
        story = json.load(f)
    sid = story["id"]
    region = jf.replace(chr(92),"/").split("/")[-2]
    base = f"assets/audio/{region}/{sid}"
    os.makedirs(base, exist_ok=True)
    print(f"\n>>> {story.get('title_fil', sid)}")
    for ch in story.get("chapters", []):
        n = str(ch["chapter"]).zfill(2)
        fp = f"{base}/ch{n}_fil.mp3"
        ep = f"{base}/ch{n}_eng.mp3"
        if not os.path.exists(fp):
            generate(ch["text_fil"], VOICE_FIL, fp)
        else:
            print(f"  SKIP {os.path.basename(fp)}")
        if not os.path.exists(ep):
            generate(ch["text_eng"], VOICE_ENG, ep)
        else:
            print(f"  SKIP {os.path.basename(ep)}")

print("\nDONE! Lahat ng audio files ay nagawa na!")
