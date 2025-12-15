#!/usr/bin/env python3
import re
import sys
import unicodedata
from pathlib import Path

def slugify(text: str) -> str:
    text = unicodedata.normalize("NFKD", text)
    text = "".join(ch for ch in text if not unicodedata.combining(ch))
    text = text.lower()
    text = re.sub(r"[^\w\s-]", "", text)
    text = re.sub(r"[\s_-]+", "-", text).strip("-")
    return text or "section"

def unique_id(base: str, used: set[str]) -> str:
    if base not in used:
        used.add(base)
        return base
    i = 2
    while f"{base}-{i}" in used:
        i += 1
    uid = f"{base}-{i}"
    used.add(uid)
    return uid

def main(inp: Path, out: Path) -> int:
    html = inp.read_text(encoding="utf-8", errors="replace")

    heading_re = re.compile(
        r'(?P<open><h(?P<lvl>[2-4])\s+class="(?P<cls>[^"]*\bltx_title\b[^"]*)")(?P<attrs>[^>]*)>'
        r'(?P<body>.*?)</h(?P=lvl)>',
        re.DOTALL | re.IGNORECASE
    )

    used_ids = set(re.findall(r'\sid="([^"]+)"', html))
    toc_items = []

    def strip_tags(s: str) -> str:
        s = re.sub(r"<[^>]+>", " ", s)
        s = re.sub(r"\s+", " ", s).strip()
        return s

    def add_id(m: re.Match) -> str:
        open_tag = m.group("open")
        attrs = m.group("attrs")
        body = m.group("body")
        lvl = int(m.group("lvl"))
        cls = m.group("cls")

        if re.search(r'\sid="[^"]+"', attrs):
            return m.group(0)

        text = strip_tags(body)
        base = slugify(text)

        if "ltx_title_section" in cls:
            base = f"sec-{base}"
        elif "ltx_title_subsection" in cls:
            base = f"subsec-{base}"
        elif "ltx_title_subsubsection" in cls:
            base = f"subsubsec-{base}"

        hid = unique_id(base, used_ids)
        toc_items.append((lvl, hid, text))

        return f'{open_tag} id="{hid}"{attrs}>{body}</h{lvl}>'

    new_html = heading_re.sub(add_id, html)

    if toc_items:
        toc_lines = [
            '<nav class="toc" aria-label="Table of contents">',
            '<h2>Contents</h2>',
            '<ul>'
        ]
        base_lvl = toc_items[0][0]
        prev_lvl = base_lvl

        for lvl, hid, text in toc_items:
            while lvl > prev_lvl:
                toc_lines.append("<ul>")
                prev_lvl += 1
            while lvl < prev_lvl:
                toc_lines.append("</ul>")
                prev_lvl -= 1
            toc_lines.append(f'<li><a href="#{hid}">{text}</a></li>')

        while prev_lvl > base_lvl:
            toc_lines.append("</ul>")
            prev_lvl -= 1

        toc_lines.append("</ul></nav>")
        toc_block = "\n".join(toc_lines)

        body_open = re.search(r"<body\b[^>]*>", new_html, re.IGNORECASE)
        if body_open:
            insert_at = body_open.end()
            new_html = new_html[:insert_at] + "\n" + toc_block + "\n" + new_html[insert_at:]
        else:
            new_html = toc_block + "\n" + new_html

    out.write_text(new_html, encoding="utf-8")
    return 0

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: postprocess_html.py INPUT.html OUTPUT.html", file=sys.stderr)
        sys.exit(2)
    sys.exit(main(Path(sys.argv[1]), Path(sys.argv[2])))

