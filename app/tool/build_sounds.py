#!/usr/bin/env python3
"""Builds app/assets/sounds/*.ogg from Kenney's CC0 sound packs.

Sources (all CC0 1.0, credit optional), downloaded from OpenGameArt:
  - Interface Sounds  https://opengameart.org/content/interface-sounds        (kenney_interfaceSounds.zip)
  - Music Jingles     https://opengameart.org/content/85-short-music-jingles  (jingleSounds_Kenney.zip)
  - RPG Sounds        https://opengameart.org/content/50-rpg-sound-effects    (RPGsounds_Kenney.zip)

Each source is converted to mono, trimmed of leading/trailing silence, given a
short fade-out (no click), loudness-matched and re-encoded as OGG Vorbis so the
ten effects share one volume, stay small (README: < 50 KB each, < 1 MB total)
and work on iOS and Android with a single format.

Usage:
  python3 -m venv venv && venv/bin/pip install numpy soundfile
  venv/bin/python tool/build_sounds.py /path/to/folder/with/the/three/unzipped/packs
"""
import os
import sys

import numpy as np
import soundfile as sf

SRC = sys.argv[1] if len(sys.argv) > 1 else "."
OUT = os.path.join(os.path.dirname(__file__), "..", "assets", "sounds")

INTERFACE = "kenney_interfaceSounds/Audio"
JINGLES = "jingleSounds_Kenney/OGG"
RPG = "RPGsounds_Kenney/OGG"

# README 7.3 name -> list of source files, concatenated in order.
SOUNDS = {
    "ding": [f"{INTERFACE}/confirmation_001.ogg"],
    "soft_error": [f"{INTERFACE}/error_008.ogg"],
    "coins": [f"{RPG}/handleCoins.ogg"],
    "flame": [f"{JINGLES}/jingles_STEEL/jingles_STEEL16.ogg"],
    "scan_done": [f"{INTERFACE}/confirmation_002.ogg"],
    # Rising sweep followed by a steel-drum chime.
    "gift_open": [
        f"{JINGLES}/jingles_HIT/jingles_HIT15.ogg",
        f"{JINGLES}/jingles_STEEL/jingles_STEEL08.ogg",
    ],
    "level_up": [f"{JINGLES}/jingles_STEEL/jingles_STEEL02.ogg"],
    "league_up": [f"{JINGLES}/jingles_STEEL/jingles_STEEL08.ogg"],
    "lesson_done": [f"{JINGLES}/jingles_STEEL/jingles_STEEL10.ogg"],
    "uh_oh": [f"{INTERFACE}/question_001.ogg"],
}

TARGET_RMS = 0.10  # about -20 dBFS
MIN_RMS = 0.063  # about -24 dBFS: quieter sounds get soft-limited upwards
PEAK_LIMIT = 0.708  # -3 dBFS
GAP_SECONDS = 0.03


def load_mono(path):
    data, rate = sf.read(os.path.join(SRC, path), always_2d=True)
    return data.mean(axis=1), rate


def resample(x, from_rate, to_rate):
    if from_rate == to_rate:
        return x
    n = int(round(len(x) * to_rate / from_rate))
    return np.interp(np.linspace(0, len(x) - 1, n), np.arange(len(x)), x)


def trim(x, rate):
    active = np.flatnonzero(np.abs(x) > 0.01)
    if active.size == 0:
        return x
    start = max(0, active[0] - int(0.003 * rate))
    end = min(len(x), active[-1] + int(0.02 * rate))
    return x[start:end]


def fade_out(x, rate, seconds=0.012):
    n = min(len(x), int(seconds * rate))
    x = x.copy()
    x[-n:] *= np.linspace(1, 0, n)
    return x


def build(name, files):
    rate = 44100
    parts = []
    for path in files:
        x, r = load_mono(path)
        parts.append(trim(resample(x, r, rate), rate))
        parts.append(np.zeros(int(GAP_SECONDS * rate)))
    x = fade_out(np.concatenate(parts[:-1]), rate)
    rms = float(np.sqrt(np.mean(x**2)))
    peak = float(np.abs(x).max())
    gain = min(TARGET_RMS / rms, PEAK_LIMIT / peak)
    x = x * gain
    # Sparse transients (coins, a short "bonk") hit the peak limit long before
    # reaching a comparable average level. A soft limiter raises their body
    # without ever exceeding the peak limit.
    if np.sqrt(np.mean(x**2)) < MIN_RMS:
        for drive in np.arange(1.2, 8.0, 0.1):
            y = PEAK_LIMIT * np.tanh(drive * x / PEAK_LIMIT)
            if np.sqrt(np.mean(y**2)) >= MIN_RMS:
                break
        x = y
    out = os.path.join(OUT, f"{name}.ogg")
    sf.write(out, x, rate, format="OGG", subtype="VORBIS")
    size = os.path.getsize(out)
    print(f"{name:12s} {len(x) / rate:4.2f}s  gain x{gain:4.2f}  {size / 1024:5.1f} KB")
    return size


os.makedirs(OUT, exist_ok=True)
total = sum(build(name, files) for name, files in SOUNDS.items())
print(f"total {total / 1024:.1f} KB")
