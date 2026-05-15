"""
Right-click PDF merger.

Usage:
  python merge_pdf_direct.py file1.pdf file2.pdf ...
  python merge_pdf_direct.py totalcmd_list_file.txt

The output is saved next to the first PDF as merged.pdf. If that name already
exists, merged_001.pdf, merged_002.pdf, ... is used instead.
"""

from __future__ import annotations

import os
import re
import sys
from pathlib import Path

try:
    from pypdf import PdfWriter
except ImportError:
    PdfWriter = None


APP_TITLE = "PDF Merge"


def show_message(title: str, message: str, error: bool = False) -> None:
    """Show a native Windows message box, with console fallback."""
    try:
        import ctypes

        flags = 0x10 if error else 0x40
        ctypes.windll.user32.MessageBoxW(None, message, title, flags)
    except Exception:
        print(f"{title}: {message}")


def natural_key(path: str) -> list[object]:
    name = os.path.basename(path).lower()
    return [int(part) if part.isdigit() else part for part in re.split(r"(\d+)", name)]


def read_list_file(path: str) -> list[str]:
    data = Path(path).read_bytes()
    for encoding in ("utf-8-sig", "utf-16", "mbcs"):
        try:
            text = data.decode(encoding)
            break
        except UnicodeError:
            continue
    else:
        text = data.decode(errors="ignore")

    files: list[str] = []
    for line in text.splitlines():
        item = line.strip().strip('"')
        if item:
            files.append(item)
    return files


def collect_pdf_files(args: list[str]) -> list[str]:
    files: list[str] = []
    for arg in args:
        arg = arg.strip().strip('"')
        if not arg:
            continue

        if arg.lower().endswith(".pdf"):
            files.append(arg)
            continue

        if os.path.isfile(arg):
            files.extend(read_list_file(arg))

    seen = set()
    pdfs: list[str] = []
    for item in files:
        if not item.lower().endswith(".pdf"):
            continue
        full = os.path.abspath(item)
        key = os.path.normcase(full)
        if key in seen or not os.path.isfile(full):
            continue
        seen.add(key)
        pdfs.append(full)

    return sorted(pdfs, key=natural_key)


def next_output_path(first_pdf: str) -> str:
    folder = os.path.dirname(os.path.abspath(first_pdf))
    base = os.path.join(folder, "merged.pdf")
    if not os.path.exists(base):
        return base

    for i in range(1, 1000):
        candidate = os.path.join(folder, f"merged_{i:03d}.pdf")
        if not os.path.exists(candidate):
            return candidate

    raise RuntimeError("Could not find an available output file name.")


def merge_pdfs(files: list[str], out_path: str) -> None:
    writer = PdfWriter()
    try:
        for file in files:
            writer.append(file)
        with open(out_path, "wb") as fp:
            writer.write(fp)
    finally:
        writer.close()


def main(argv: list[str]) -> int:
    if PdfWriter is None:
        show_message(
            APP_TITLE,
            "pypdf is not installed, so PDF files cannot be merged.\n\n"
            "Please run: python -m pip install pypdf",
            error=True,
        )
        return 1

    files = collect_pdf_files(argv)
    if len(files) < 2:
        show_message(APP_TITLE, "Please select at least 2 PDF files.", error=True)
        return 1

    try:
        out_path = next_output_path(files[0])
        merge_pdfs(files, out_path)
    except Exception as ex:
        show_message(APP_TITLE, f"Merge failed:\n{ex}", error=True)
        return 1

    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
