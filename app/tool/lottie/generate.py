#!/usr/bin/env python3
"""Generates Sipho's hand-built Lottie animations into assets/animations/.

Run from app/:  python3 tool/lottie/generate.py

Each animation is plain Lottie JSON (shape layers, transforms, easing), so it plays with the
`lottie` Flutter package and can be opened in LottieFiles / After Effects. Edit the constants
below and re-run rather than editing the JSON by hand.
"""
import json
import math
import os

OUT = os.path.join(os.path.dirname(__file__), '..', '..', 'assets', 'animations')

GOLD = '#F5B82E'
GOLD_DARK = '#E09A12'
GOLD_LIGHT = '#FFE08A'
MINT = '#5ED39A'
PINK = '#FF8FA3'
WHITE = '#FFFFFF'

EASE_I = {'x': [0.667], 'y': [1]}
EASE_O = {'x': [0.333], 'y': [0]}


def rgba(hex_color):
    h = hex_color.lstrip('#')
    return [int(h[i:i + 2], 16) / 255 for i in (0, 2, 4)] + [1]


def val(v):
    return {'a': 0, 'k': v}


def anim(keys):
    """keys: [(frame, value), ...]; eased in and out between keyframes."""
    k = []
    for i, (t, s) in enumerate(keys):
        frame = {'t': t, 's': s}
        if i < len(keys) - 1:
            frame['i'] = EASE_I
            frame['o'] = EASE_O
        k.append(frame)
    return {'a': 1, 'k': k}


def fill(color):
    return {'ty': 'fl', 'c': val(rgba(color)), 'o': val(100), 'r': 1, 'nm': 'Fill'}


def stroke(color, width):
    return {'ty': 'st', 'c': val(rgba(color)), 'o': val(100), 'w': val(width),
            'lc': 2, 'lj': 2, 'nm': 'Stroke'}


def ellipse(cx, cy, w, h):
    return {'ty': 'el', 'p': val([cx, cy]), 's': val([w, h]), 'nm': 'Ellipse'}


def rect(cx, cy, w, h, r=0):
    return {'ty': 'rc', 'p': val([cx, cy]), 's': val([w, h]), 'r': val(r), 'nm': 'Rect'}


def star(outer, inner, points=4, rotation=0):
    return {'ty': 'sr', 'sy': 1, 'd': 1, 'pt': val(points), 'p': val([0, 0]),
            'r': val(rotation), 'ir': val(inner), 'is': val(0), 'or': val(outer),
            'os': val(0), 'nm': 'Star'}


def group(items, name='Group'):
    transform = {'ty': 'tr', 'p': val([0, 0]), 'a': val([0, 0]), 's': val([100, 100]),
                 'r': val(0), 'o': val(100), 'sk': val(0), 'sa': val(0)}
    return {'ty': 'gr', 'it': items + [transform], 'nm': name}


def ks(p, s=None, r=0, o=100):
    return {
        'a': val([0, 0]),
        'p': p if isinstance(p, dict) else val(p),
        's': s if isinstance(s, dict) else val(s or [100, 100, 100]),
        'r': r if isinstance(r, dict) else val(r),
        'o': o if isinstance(o, dict) else val(o),
    }


def layer(index, name, shapes, transform, end):
    return {'ddd': 0, 'ind': index, 'ty': 4, 'nm': name, 'sr': 1, 'ks': transform,
            'ao': 0, 'shapes': shapes, 'ip': 0, 'op': end, 'st': 0, 'bm': 0}


def composition(name, width, height, frames, layers, fps=30):
    return {'v': '5.7.4', 'fr': fps, 'ip': 0, 'op': frames, 'w': width, 'h': height,
            'nm': name, 'ddd': 0, 'assets': [], 'layers': layers}


def write(filename, data):
    path = os.path.join(OUT, filename)
    with open(path, 'w') as handle:
        json.dump(data, handle, separators=(',', ':'))
    print(f'{filename}: {os.path.getsize(path)} bytes')


def trophy_shine():
    """League promotion: the cup pops in with an overshoot, then three sparkles glint (one shot)."""
    frames = 66
    cup = group([
        rect(0, -10, 40, 32, 7), ellipse(0, 6, 40, 30), fill(GOLD)], 'Cup')
    highlight = group([rect(-10, -10, 6, 22, 3), fill(GOLD_LIGHT)], 'Highlight')
    handles = group([
        ellipse(-25, -12, 18, 20), ellipse(25, -12, 18, 20), stroke(GOLD_DARK, 5)], 'Handles')
    stem = group([rect(0, 24, 9, 12), fill(GOLD_DARK)], 'Stem')
    base = group([rect(0, 33, 38, 9, 4), fill(GOLD_DARK)], 'Base')
    trophy_scale = anim([
        (0, [0, 0, 100]), (16, [112, 112, 100]), (24, [96, 96, 100]), (30, [100, 100, 100])])
    trophy_rotation = anim([(0, -14), (16, 5), (24, -2), (30, 0)])
    layers = [
        layer(1, 'Sparkle C', [group([star(9, 2.5), fill(GOLD)])],
              ks([88, 94], anim([(32, [0, 0, 100]), (40, [100, 100, 100]), (50, [0, 0, 100])]),
                 anim([(32, 0), (50, 90)])), frames),
        layer(2, 'Sparkle B', [group([star(7, 2), fill(GOLD_DARK)])],
              ks([26, 40], anim([(24, [0, 0, 100]), (32, [100, 100, 100]), (42, [0, 0, 100])]),
                 anim([(24, 0), (42, 90)])), frames),
        layer(3, 'Sparkle A', [group([star(10, 3), fill(GOLD)])],
              ks([92, 28], anim([(18, [0, 0, 100]), (27, [100, 100, 100]), (38, [0, 0, 100])]),
                 anim([(18, 0), (38, 90)])), frames),
        layer(4, 'Trophy', [handles, cup, highlight, stem, base],
              ks([60, 62], trophy_scale, trophy_rotation), frames),
    ]
    return composition('trophy_shine', 120, 120, frames, layers)


def gift_sparkles():
    """Gift opening: an expanding ring and ten sparkles burst outward from the box (one shot)."""
    frames = 42
    colors = [GOLD, MINT, PINK, GOLD_LIGHT, WHITE]
    layers = []
    for i in range(10):
        angle = math.radians(i * 36 - 90)
        distance = 100 if i % 2 == 0 else 78
        dx, dy = math.cos(angle) * distance, math.sin(angle) * distance
        size = 11 if i % 2 == 0 else 8
        start = [120, 120]
        end = [round(120 + dx, 1), round(120 + dy, 1)]
        layers.append(layer(
            i + 1, f'Spark {i}',
            [group([star(size, size * 0.3), fill(colors[i % len(colors)])])],
            ks(anim([(0, start), (30, end)]),
               anim([(0, [0, 0, 100]), (8, [110, 110, 100]), (34, [0, 0, 100])]),
               anim([(0, 0), (34, 120 if i % 2 == 0 else -120)]),
               anim([(0, 100), (22, 100), (34, 0)])),
            frames))
    ring = group([ellipse(0, 0, 60, 60), stroke(GOLD, 5)], 'Ring')
    layers.append(layer(
        11, 'Ring', [ring],
        ks([120, 120], anim([(0, [20, 20, 100]), (26, [170, 170, 100])]), 0,
           anim([(0, 90), (26, 0)])),
        frames))
    return composition('gift_sparkles', 240, 240, frames, layers)


def level_up():
    """Level up: a gold star pops with an overshoot while a mint ring expands (one shot)."""
    frames = 54
    star_scale = anim([
        (0, [0, 0, 100]), (12, [118, 118, 100]), (20, [94, 94, 100]), (28, [100, 100, 100])])
    star_rot = anim([(0, -25), (14, 8), (24, -3), (30, 0)])
    layers = [
        layer(1, 'Ring', [group([ellipse(0, 0, 70, 70), stroke(MINT, 5)], 'Ring')],
              ks([90, 90], anim([(0, [30, 30, 100]), (28, [160, 160, 100])]), 0,
                 anim([(0, 90), (28, 0)])), frames),
        layer(2, 'Spark C', [group([star(8, 2.5), fill(GOLD_LIGHT)])],
              ks([148, 48], anim([(18, [0, 0, 100]), (28, [110, 110, 100]), (40, [0, 0, 100])]),
                 anim([(18, 0), (40, 100)])), frames),
        layer(3, 'Spark B', [group([star(7, 2), fill(MINT)])],
              ks([34, 56], anim([(14, [0, 0, 100]), (24, [100, 100, 100]), (36, [0, 0, 100])]),
                 anim([(14, 0), (36, -90)])), frames),
        layer(4, 'Spark A', [group([star(9, 3), fill(GOLD)])],
              ks([142, 132], anim([(10, [0, 0, 100]), (20, [110, 110, 100]), (34, [0, 0, 100])]),
                 anim([(10, 0), (34, 80)])), frames),
        layer(5, 'Star', [group([star(28, 12, points=5), fill(GOLD)])],
              ks([90, 90], star_scale, star_rot), frames),
    ]
    return composition('level_up', 180, 180, frames, layers)


if __name__ == '__main__':
    os.makedirs(OUT, exist_ok=True)
    write('trophy_shine.json', trophy_shine())
    write('gift_sparkles.json', gift_sparkles())
    write('level_up.json', level_up())
