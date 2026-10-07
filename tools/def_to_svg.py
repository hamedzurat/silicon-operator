#!/usr/bin/env python
"""Make a simple SVG preview of placed cells and routed nets from DEF + LEF."""

import os
import re
import sys
from xml.sax.saxutils import escape


LAYER_COLORS = {
    "Metal1": "#8c564b", "Metal2": "#1f77b4", "Metal3": "#2ca02c",
    "Metal4": "#d62728", "Metal5": "#9467bd", "Metal6": "#ff7f0e",
    "Metal7": "#17becf", "Metal8": "#e377c2", "Metal9": "#7f7f7f",
}


def read_text(filename):
    stream = open(filename, "r")
    try:
        return stream.read()
    finally:
        stream.close()


def parse_macro_sizes(lef_text):
    sizes = {}
    for match in re.finditer(r"(?ms)^MACRO\s+(\S+)(.*?)^END\s+\1\s*$", lef_text):
        size = re.search(r"(?m)^\s*SIZE\s+([0-9.]+)\s+BY\s+([0-9.]+)", match.group(2))
        if size:
            sizes[match.group(1)] = (float(size.group(1)), float(size.group(2)))
    return sizes


def render(def_file, lef_file, output_file):
    data = read_text(def_file)
    macros = parse_macro_sizes(read_text(lef_file))

    units = re.search(r"UNITS\s+DISTANCE\s+MICRONS\s+(\d+)", data)
    scale = float(units.group(1)) if units else 1.0
    die = re.search(r"DIEAREA\s+\(\s*(-?\d+)\s+(-?\d+)\s*\)\s+\(\s*(-?\d+)\s+(-?\d+)\s*\)", data)
    if not die:
        raise ValueError("DEF is missing a DIEAREA")
    die_x1, die_y1, die_x2, die_y2 = [float(value) / scale for value in die.groups()]

    core_values = {}
    for key in ("LL_X", "LL_Y", "UR_X", "UR_Y"):
        match = re.search(r"FE_CORE_BOX_%s\s+REAL\s+([-0-9.]+)" % key, data)
        if match:
            core_values[key] = float(match.group(1))
    if len(core_values) != 4:
        core_values = {"LL_X": die_x1, "LL_Y": die_y1,
                       "UR_X": die_x2, "UR_Y": die_y2}

    components = []
    block = re.search(r"(?ms)^COMPONENTS\s+\d+\s*;(.*?)^END COMPONENTS", data)
    if block:
        pattern = r"-\s+(\S+)\s+(\S+)\s+\+\s+(?:PLACED|FIXED|COVER)\s+\(\s*(-?\d+)\s+(-?\d+)\s*\)\s+(\S+)"
        for name, macro, x, y, orient in re.findall(pattern, block.group(1)):
            cell_w, cell_h = macros.get(macro, (1.0, 1.0))
            components.append((name, macro, int(x) / scale, int(y) / scale, cell_w, cell_h))

    pins = []
    pin_block = re.search(r"(?ms)^PINS\s+\d+\s*;(.*?)^END PINS", data)
    if pin_block:
        pattern = r"(?s)-\s+(\S+)\s+\+\s+NET\s+\S+.*?\+\s+PLACED\s+\(\s*(-?\d+)\s+(-?\d+)\s*\)"
        for name, x, y in re.findall(pattern, pin_block.group(1)):
            pins.append((name, int(x) / scale, int(y) / scale))

    net_block = re.search(r"(?ms)^NETS\s+\d+\s*;(.*?)^END NETS", data)
    nets = []
    if net_block:
        for net in re.split(r"(?m)^\s*-\s+", net_block.group(1)):
            segments = []
            pattern = r"\+\s+ROUTED\s+(\w+)\s+\(\s*(-?\d+|\*)\s+(-?\d+|\*)\s*\)\s+\(\s*(-?\d+|\*)\s+(-?\d+|\*)\s+[-\d]+\s*\)"
            for layer, x1, y1, x2, y2 in re.findall(pattern, net):
                if x1 == "*":
                    continue
                start = (float(x1) / scale, float(y1) / scale)
                end_x = x1 if x2 == "*" else x2
                end_y = y1 if y2 == "*" else y2
                end = (float(end_x) / scale, float(end_y) / scale)
                segments.append((layer, start, end))
            if segments:
                nets.append(segments)

    width, height = 900.0, 700.0
    margin = 55.0
    world_w = die_x2 - die_x1
    world_h = die_y2 - die_y1
    factor = min((width - 2 * margin) / world_w, (height - 2 * margin) / world_h)
    draw_w, draw_h = world_w * factor, world_h * factor
    offset_x = (width - draw_w) / 2.0
    offset_y = (height - draw_h) / 2.0

    def point(x, y):
        return (offset_x + (x - die_x1) * factor,
                height - offset_y - (y - die_y1) * factor)

    def rect(x, y, w, h):
        px, py = point(x, y + h)
        return px, py, w * factor, h * factor

    parts = [
        '<svg xmlns="http://www.w3.org/2000/svg" width="900" height="700" viewBox="0 0 900 700">',
        '<rect width="100%" height="100%" fill="#fff"/>',
        '<text x="20" y="25" font-size="14" font-weight="bold" fill="#222">%s - routed floorplan preview</text>' % escape(os.path.basename(def_file)),
    ]

    dx, dy, dw, dh = rect(die_x1, die_y1, world_w, world_h)
    parts.append('<rect x="%.2f" y="%.2f" width="%.2f" height="%.2f" fill="#fafafa" stroke="#111" stroke-width="2"/>' % (dx, dy, dw, dh))
    core_x1, core_y1 = core_values["LL_X"], core_values["LL_Y"]
    core_w = core_values["UR_X"] - core_x1
    core_h = core_values["UR_Y"] - core_y1
    cx, cy, cw, ch = rect(core_x1, core_y1, core_w, core_h)
    parts.append('<rect x="%.2f" y="%.2f" width="%.2f" height="%.2f" fill="#f2f2f2" stroke="#888" stroke-dasharray="5,4"/>' % (cx, cy, cw, ch))

    for segments in nets:
        for layer, start, end in segments:
            x1, y1 = point(start[0], start[1])
            x2, y2 = point(end[0], end[1])
            color = LAYER_COLORS.get(layer, "#333")
            parts.append('<line x1="%.2f" y1="%.2f" x2="%.2f" y2="%.2f" stroke="%s" stroke-width="2"/>' % (x1, y1, x2, y2, color))

    for name, macro, x, y, cell_w, cell_h in components:
        x1, y1, w, h = rect(x, y, cell_w, cell_h)
        parts.append('<rect x="%.2f" y="%.2f" width="%.2f" height="%.2f" fill="#ffe08a" stroke="#222" stroke-width="1.5"/>' % (x1, y1, w, h))
        parts.append('<text x="%.2f" y="%.2f" font-size="10" font-weight="bold" fill="#222">%s (%s)</text>' % (x1 + 2, y1 + h / 2.0, escape(name), escape(macro)))

    for name, x, y in pins:
        px, py = point(x, y)
        parts.append('<circle cx="%.2f" cy="%.2f" r="4" fill="#d62728" stroke="#fff" stroke-width="1"/>' % (px, py))
        parts.append('<text x="%.2f" y="%.2f" font-size="11" fill="#222">%s</text>' % (px + 5, py - 4, escape(name)))

    legend_y = 670
    for index, layer in enumerate(sorted(set(segment[0] for net in nets for segment in net))):
        x = 20 + index * 85
        parts.append('<line x1="%d" y1="%d" x2="%d" y2="%d" stroke="%s" stroke-width="3"/>' % (x, legend_y, x + 18, legend_y, LAYER_COLORS.get(layer, "#333")))
        parts.append('<text x="%d" y="%d" font-size="11" fill="#222">%s</text>' % (x + 22, legend_y + 4, escape(layer)))
    parts.append('<text x="20" y="690" font-size="11" fill="#222">Preview from routed DEF and cell LEF; not a GDS or signoff layout.</text>')
    parts.append('</svg>')

    stream = open(output_file, "w")
    try:
        stream.write("\n".join(parts) + "\n")
    finally:
        stream.close()


if __name__ == "__main__":
    if len(sys.argv) != 4:
        raise SystemExit("usage: %s INPUT.def CELLS.lef OUTPUT.svg" % sys.argv[0])
    render(sys.argv[1], sys.argv[2], sys.argv[3])
