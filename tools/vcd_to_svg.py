#!/usr/bin/env python
"""Convert scalar VCD signals into a standalone SVG waveform image.

Compatible with the Python 2.x runtime shipped in the Cadence VM and Python 3.
"""

import sys
from collections import OrderedDict


def parse_vcd(filename):
    identifiers = {}
    changes = OrderedDict()
    timestamp = 0
    in_definitions = True
    scope_depth = 0
    reading_timescale = False
    timescale_tokens = []

    stream = open(filename, "r")
    try:
        for line in stream:
            fields = line.split()
            if not fields:
                continue

            if fields[0] == "$timescale":
                reading_timescale = True
                timescale_tokens = fields[1:]
                if "$end" in timescale_tokens:
                    reading_timescale = False
            elif reading_timescale:
                timescale_tokens.extend(fields)
                if "$end" in fields:
                    reading_timescale = False
            elif fields[0] == "$enddefinitions":
                in_definitions = False
            elif in_definitions and fields[0] == "$scope":
                scope_depth += 1
            elif in_definitions and fields[0] == "$upscope":
                scope_depth -= 1
            elif (in_definitions and scope_depth == 1 and
                  fields[0] == "$var" and len(fields) >= 5):
                name = fields[4]
                if fields[2] == "1" and name not in changes:
                    identifiers[fields[3]] = name
                    changes[name] = [(0, "x")]
            elif not in_definitions and fields[0].startswith("#"):
                timestamp = int(fields[0][1:])
            elif not in_definitions and fields[0][0] in "01xXzZ":
                name = identifiers.get(fields[0][1:])
                if name:
                    value = fields[0][0].lower()
                    if changes[name][-1][1] != value:
                        changes[name].append((timestamp, value))
    finally:
        stream.close()

    tokens = [token for token in timescale_tokens if token != "$end"]
    if len(tokens) >= 2:
        unit = tokens[1].lower()
    else:
        unit = "ns"
    ns_per_unit = {"s": 1e9, "ms": 1e6, "us": 1e3,
                   "ns": 1.0, "ps": 1e-3, "fs": 1e-6}.get(unit, 1.0)
    multiplier = float(tokens[0]) if len(tokens) >= 2 else 1.0
    ns_per_tick = multiplier * ns_per_unit
    return changes, timestamp, ns_per_tick


def render(source, destination):
    from xml.sax.saxutils import escape

    signals, end_time, ns_per_tick = parse_vcd(source)
    if end_time <= 0:
        raise ValueError("VCD contains no timed signal changes")
    signal_names = list(signals)
    if not signal_names:
        raise ValueError("VCD contains no scalar signals")

    width = 800
    row_height = 58
    left = 90
    right = 24
    top = 36
    height = top + row_height * len(signal_names) + 36
    plot_width = width - left - right

    def x_at(tick):
        return left + plot_width * float(tick) / end_time

    parts = [
        '<svg xmlns="http://www.w3.org/2000/svg" width="%d" height="%d" viewBox="0 0 %d %d">' % (width, height, width, height),
        '<rect width="100%" height="100%" fill="#fff"/>',
        '<text x="16" y="22" font-size="14" fill="#222">Simulation waveform (time in ns)</text>',
    ]

    for index, name in enumerate(signal_names):
        events = signals[name]
        y = top + index * row_height
        high = y + 12
        low = y + 34
        parts.append('<text x="20" y="%d" font-size="13" font-weight="bold" fill="#222">%s</text>' % (y + 27, escape(name)))
        parts.append('<line x1="%d" y1="%d" x2="%d" y2="%d" stroke="#ddd"/>' % (left, y + 40, width - right, y + 40))

        def level(value):
            if value == "1":
                return high
            if value == "0":
                return low
            return y + 23

        points = [(x_at(0), level(events[0][1]))]
        current = events[0][1]
        for tick, value in events[1:]:
            x = x_at(tick)
            points.append((x, level(current)))
            points.append((x, level(value)))
            current = value
        points.append((x_at(end_time), level(current)))
        path = " ".join(("M" if point == 0 else "L") + "%.1f,%.1f" % coords
                        for point, coords in enumerate(points))
        parts.append('<path d="%s" fill="none" stroke="#1769aa" stroke-width="2"/>' % path)

    axis_y = top + len(signal_names) * row_height - 8
    parts.append('<line x1="%d" y1="%d" x2="%d" y2="%d" stroke="#ddd"/>' % (left, axis_y, width - right, axis_y))
    for tick in range(5):
        time = end_time * tick / 4.0
        x = x_at(time)
        label = "%.3g" % (time * ns_per_tick)
        parts.append('<line x1="%.1f" y1="%d" x2="%.1f" y2="%d" stroke="#ddd"/>' % (x, top - 4, x, axis_y))
        parts.append('<text x="%.1f" y="%d" font-size="12" fill="#222">%s</text>' % (x - 10, height - 8, escape(label)))
    parts.append("</svg>")

    output = open(destination, "w")
    try:
        output.write("\n".join(parts) + "\n")
    finally:
        output.close()


if __name__ == "__main__":
    if len(sys.argv) != 3:
        raise SystemExit("usage: %s INPUT.vcd OUTPUT.svg" % sys.argv[0])
    render(sys.argv[1], sys.argv[2])
