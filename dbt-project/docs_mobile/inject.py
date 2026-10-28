"""Inline mobile.css and mobile.js into a static dbt docs page.

Usage: python inject.py <static_index.html> <output.html>
"""

import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent


def main(source: str, target: str) -> None:
    html = Path(source).read_text(encoding="utf-8")
    css = (HERE / "mobile.css").read_text(encoding="utf-8")
    js = (HERE / "mobile.js").read_text(encoding="utf-8")

    if html.count("</head>") != 1 or html.count("</body>") != 1:
        sys.exit(f"{source}: expected exactly one </head> and one </body>")

    html = html.replace("</head>", f"<style>\n{css}</style>\n</head>")
    html = html.replace("</body>", f"<script>\n{js}</script>\n</body>")

    Path(target).parent.mkdir(parents=True, exist_ok=True)
    Path(target).write_text(html, encoding="utf-8")
    print(f"wrote {target}")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    main(sys.argv[1], sys.argv[2])
