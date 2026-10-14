#!/usr/bin/env python3
"""Generate a scalable Monet icon theme from Papirus without rasterizing SVGs."""

import argparse
import json
import os
from pathlib import Path
import re
import xml.etree.ElementTree as ET


SVG = "http://www.w3.org/2000/svg"
ET.register_namespace("", SVG)
ET.register_namespace("xlink", "http://www.w3.org/1999/xlink")
PAINTS = {"fill", "stroke", "color", "stop-color", "flood-color", "lighting-color"}
SHAPES = {"path", "rect", "circle", "ellipse", "polygon", "polyline", "text", "use"}
CONTEXTS = {
    "actions": "Actions", "apps": "Applications", "categories": "Categories",
    "devices": "Devices", "emblems": "Emblems", "emotes": "Emotes",
    "mimetypes": "MimeTypes", "places": "Places", "status": "Status",
    "animations": "Animations", "panel": "Status",
}
NAMED = dict(zip(
    "black silver gray white maroon red purple fuchsia green lime olive yellow navy blue teal aqua orange pink brown gold violet transparent".split(),
    "000000 c0c0c0 808080 ffffff 800000 ff0000 800080 ff00ff 008000 00ff00 808000 ffff00 000080 0000ff 008080 00ffff ffa500 ffc0cb a52a2a ffd700 ee82ee 00000000".split(),
))
NAMED.update(grey=NAMED["gray"], cyan=NAMED["aqua"], magenta=NAMED["fuchsia"])
DECLARATION = re.compile(r"(^|[;{])\s*([\w-]+)\s*:\s*([^;{}]+)")
REFERENCE = re.compile(r"url\(\s*['\"]?#([^\s)'\"]+)['\"]?\s*\)")


def color(value):
    """Return RGBA, or None for non-solid SVG paints; reject unknown colors."""
    value = value.strip().lower()
    if value in {"none", "inherit", "currentcolor"}:
        return None
    if REFERENCE.fullmatch(value):
        return None
    if value in NAMED:
        value = "#" + NAMED[value]
    if re.fullmatch(r"#[0-9a-f]{3,4}", value):
        value = "#" + "".join(c * 2 for c in value[1:])
    if re.fullmatch(r"#[0-9a-f]{6}(?:[0-9a-f]{2})?", value):
        channels = tuple(int(value[i:i + 2], 16) / 255 for i in range(1, len(value), 2))
        return channels if len(channels) == 4 else (*channels, 1.0)
    match = re.fullmatch(r"(rgb|rgba)\(([^()]+)\)", value)
    if match:
        parts = [part.strip() for part in match[2].split(",")]
        if len(parts) == (4 if match[1] == "rgba" else 3):
            try:
                channels = tuple(float(part[:-1]) / 100 if part.endswith("%") else float(part) / 255 for part in parts[:3])
                alpha = 1.0
                if len(parts) == 4:
                    alpha = float(parts[3][:-1]) / 100 if parts[3].endswith("%") else float(parts[3])
            except (ValueError, IndexError):
                raise ValueError(f"Unsupported paint color: {value!r}") from None
            if all(0 <= channel <= 1 for channel in (*channels, alpha)):
                return (*channels, alpha)
    raise ValueError(f"Unsupported paint color: {value!r}")


def declarations(text, transform):
    def replace(match):
        prefix, name, value = match.groups()
        if name.lower() not in PAINTS:
            return match[0]
        important = re.search(r"\s*!important\s*$", value, re.I)
        suffix = important[0] if important else ""
        value = value[:important.start()] if important else value
        return f"{prefix}{name}:{transform(value.strip())}{suffix}"
    return DECLARATION.sub(replace, text)


def local_name(element):
    return element.tag.rsplit("}", 1)[-1]


def protect_masks(root):
    """Protect mask luminance and mask-owned definitions without changing IDs."""
    masks = [element for element in root.iter() if local_name(element) == "mask"]
    protected = {element for mask in masks for element in mask.iter()}
    if not masks:
        return protected
    if any(local_name(element) == "style" for element in root.iter()):
        raise ValueError("Stylesheets combined with masks are not supported")
    ids = {element.get("id"): element for element in root.iter() if element.get("id")}

    def references(element):
        for key, value in element.attrib.items():
            yield from REFERENCE.findall(value)
            if key.rsplit("}", 1)[-1] == "href" and value.startswith("#"):
                yield value[1:]

    pending = list(protected)
    while pending:
        element = pending.pop()
        for reference in references(element):
            target = ids.get(reference)
            if target is not None and target not in protected:
                nodes = set(target.iter())
                pending.extend(nodes - protected)
                protected.update(nodes)
    for element in root.iter():
        if element not in protected:
            for reference in references(element):
                if ids.get(reference) in protected and ids.get(reference) not in masks:
                    raise ValueError("A mask definition shared with visible artwork is not supported")
    # Changing the root's default fill must not change an implicit mask fill.
    def inherit(element, fill="black", current="black", inside=False):
        attrs = dict(element.attrib)
        attrs.update((m[2], m[3].strip()) for m in DECLARATION.finditer(element.get("style", "")))
        if attrs.get("fill", "inherit") != "inherit":
            fill = attrs["fill"]
        if attrs.get("color", "inherit") != "inherit":
            current = attrs["color"]
        if element in protected and not inside:
            element.set("fill", fill)
            element.set("color", current)
        for child in element:
            inherit(child, fill, current, element in protected)
    inherit(root)
    return protected


def recolor(source, destination, foreground, background):
    tree = ET.parse(source)
    root = tree.getroot()
    protected = protect_masks(root)
    # Qt SVG accepts RGB paints plus separate opacity, not CSS RGBA/8-digit hex.
    def lower_alpha(element, inherited=None):
        if element in protected:
            return
        inherited = inherited or {}
        attrs = dict(inherited)
        attrs.update(element.attrib)
        style = element.get("style", "")
        attrs.update((m[2], m[3].strip()) for m in DECLARATION.finditer(style))

        def normalize(text):
            values = {m[2]: re.sub(r"\s*!important\s*$", "", m[3], flags=re.I).strip() for m in DECLARATION.finditer(text)}
            extra = []
            def paint(value, name):
                rgba = color(value)
                if rgba is None or rgba[3] in (0, 1):
                    return value
                opacity_name = name + "-opacity"
                if name not in {"fill", "stroke", "stop-color", "flood-color"}:
                    raise ValueError(f"Alpha in {name} is not supported")
                opacity_name = opacity_name.replace("-color", "")
                opacity = float(values.get(opacity_name, attrs.get(opacity_name, "1")))
                extra.append(f"{opacity_name}:{opacity * rgba[3]:.12g}")
                return "#" + "".join(f"{round(channel * 255):02x}" for channel in rgba[:3])
            def replace(match):
                prefix, name, value = match.groups()
                if name not in PAINTS:
                    return match[0]
                important = re.search(r"\s*!important\s*$", value, re.I)
                suffix = important[0] if important else ""
                value = value[:important.start()] if important else value
                return f"{prefix}{name}:{paint(value.strip(), name)}{suffix}"
            text = DECLARATION.sub(replace, text)
            return text.rstrip(";") + (";" + ";".join(extra) if extra else "")

        # Normalize attributes through the same declaration logic, keeping alpha
        # separate from geometry/group opacity and multiplicative paint opacity.
        for name, value in list(element.attrib.items()):
            if name in PAINTS and name not in {m[2] for m in DECLARATION.finditer(style)}:
                normalized = normalize(f"{name}:{value}")
                for match in DECLARATION.finditer(normalized):
                    element.set(match[2], match[3])
        if style:
            element.set("style", normalize(style))
        if local_name(element) == "style":
            element.text = re.sub(r"\{([^{}]*)\}", lambda m: "{" + normalize(m[1]) + "}", element.text or "")
        for child in element:
            lower_alpha(child, {key: value for key, value in attrs.items() if key in {"fill-opacity", "stroke-opacity"}})
    lower_alpha(root)
    for element in root.iter():
        if element in protected:
            continue
        defaults = {"stop": ("stop-color", "black"), "feFlood": ("flood-color", "black"), "feDiffuseLighting": ("lighting-color", "white"), "feSpecularLighting": ("lighting-color", "white")}
        if local_name(element) in defaults:
            name, value = defaults[local_name(element)]
            element.set(name, element.get(name, value))
        if local_name(element) == "image":
            raise ValueError("Embedded raster images cannot be recolored as SVG paints")
    colors, opaque = set(), set()

    def collect(value, opacity=1.0):
        rgba = color(value)
        if rgba is not None and rgba[3] > 0:
            colors.add(rgba[:3])
            if opacity * rgba[3] >= 0.999:
                opaque.add(rgba[:3])
        return value

    def inspect(element, fill="black", opacity=1.0):
        if element in protected:
            return
        attrs = dict(element.attrib)
        style = element.get("style", "")
        attrs.update((m[2].lower(), re.sub(r"\s*!important\s*$", "", m[3], flags=re.I).strip()) for m in DECLARATION.finditer(style))
        opacity *= float(attrs.get("opacity", "1"))
        specified_fill = attrs.get("fill", fill)
        if specified_fill.lower() != "inherit":
            fill = specified_fill
        if local_name(element) in SHAPES:
            collect("black" if fill.lower() == "currentcolor" else fill, opacity * float(attrs.get("fill-opacity", "1")))
        for name, value in attrs.items():
            if name in PAINTS:
                collect("black" if value.lower() == "currentcolor" else value, opacity * float(attrs.get(name + "-opacity", "1")))
        if local_name(element) == "style":
            declarations(element.text or "", collect)
        for child in element:
            inspect(child, fill, opacity)

    inspect(root)
    # Use per-icon luminance range, not a global threshold that erases dark logos.
    luminance = lambda rgb: sum(channel * weight for channel, weight in zip(rgb, (0.2126, 0.7152, 0.0722)))
    ordered = sorted(colors, key=lambda rgb: (luminance(rgb), rgb))
    low = luminance(ordered[0]) if ordered else 0
    high = luminance(ordered[-1]) if ordered else 1
    flat = next(iter(opaque)) if len(opaque) == 1 else None
    shades = {}
    for rank, rgb in enumerate(ordered):
        if len(ordered) == 1 or rgb == flat:
            amount = 1.0
        else:
            level = (luminance(rgb) - low) / (high - low) if high > low else rank / (len(ordered) - 1)
            # A small rank contribution separates equally bright, different hues.
            amount = 0.18 + 0.82 * (0.8 * level + 0.2 * rank / (len(ordered) - 1))
        shades[rgb] = "#" + "".join(f"{round(255 * (back + amount * (front - back))):02x}" for front, back in zip(foreground[:3], background[:3]))

    def transform(value):
        rgba = color(value)
        if rgba is None:
            return value
        if rgba[3] == 0:
            return "none"
        return shades.get(rgba[:3], "#" + "".join(f"{round(channel * 255):02x}" for channel in foreground[:3]))

    root.set("fill", root.get("fill", "black"))
    root.set("color", root.get("color", "black"))
    for element in root.iter():
        if element in protected:
            continue
        for name, value in list(element.attrib.items()):
            if name in PAINTS:
                element.set(name, transform(value))
            elif name == "style":
                element.set(name, declarations(value, transform))
        if local_name(element) == "style":
            element.text = declarations(element.text or "", transform)
    destination.parent.mkdir(parents=True, exist_ok=True)
    tree.write(destination, encoding="utf-8", xml_declaration=True)


def generate(source, output, palette):
    source = source / "48x48"
    if not source.is_dir():
        raise ValueError(f"Missing Papirus 48x48 directory: {source}")
    foreground, background = (color(palette[key]) for key in ("foreground", "background"))
    if any(value is None or value[3] != 1 for value in (foreground, background)):
        raise ValueError("Palette foreground/background must be opaque colors")
    if output.exists() and any(output.iterdir()):
        raise ValueError(f"Output theme must be empty: {output}")
    entries = []
    contexts = []
    # Follow directory aliases (e.g. categories), but retain their context names.
    for directory in sorted(source.iterdir()):
        if not directory.is_dir():
            continue
        if directory.name not in CONTEXTS:
            raise ValueError(f"Unsupported icon context: {directory.name}")
        icons = sorted(directory.glob("*.svg"))
        if icons:
            contexts.append(directory.name)
        for icon in icons:
            entries.append((icon, icon.resolve(strict=True), output / "scalable" / directory.name / icon.name))
    if not entries:
        raise ValueError(f"No SVG icons found in {source}")
    # Prefer the real filename as each canonical output; resolve aliases only once.
    entries.sort(key=lambda entry: (entry[0].is_symlink(), str(entry[0])))
    canonical = {}
    for icon, resolved, destination in entries:
        if resolved in canonical:
            destination.parent.mkdir(parents=True, exist_ok=True)
            destination.symlink_to(os.path.relpath(canonical[resolved], destination.parent))
        else:
            try:
                recolor(resolved, destination, foreground, background)
            except (ValueError, ET.ParseError) as error:
                raise ValueError(f"{icon}: {error}") from error
            canonical[resolved] = destination
    index = ["[Icon Theme]", f"Name={output.name}", "Comment=Monet native icons for Vicinae", "Inherits=hicolor", "Directories=" + ",".join(f"scalable/{context}" for context in contexts), ""]
    for context in contexts:
        index.extend([f"[scalable/{context}]", f"Context={CONTEXTS[context]}", "Type=Scalable", "Size=48", "MinSize=8", "MaxSize=512", ""])
    (output / "index.theme").write_text("\n".join(index), encoding="utf-8")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source_theme", type=Path)
    parser.add_argument("output_theme", type=Path)
    parser.add_argument("palette_json", type=Path)
    args = parser.parse_args()
    try:
        palette = json.loads(args.palette_json.read_text(encoding="utf-8"))
        generate(args.source_theme, args.output_theme, palette)
    except (OSError, ValueError, KeyError) as error:
        parser.exit(1, f"{error}\n")


if __name__ == "__main__":
    main()
