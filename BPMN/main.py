# python
import argparse
import xml.etree.ElementTree as ET
import re
import logging
from pathlib import Path
from svglib.svglib import svg2rlg
from reportlab.graphics import renderPDF

BPMN_DIR = Path("./")
EXPORT_DIR = Path("exports")


def ensure_dirs(out_dir: Path) -> None:
    out_dir.mkdir(parents=True, exist_ok=True)


def bpmn_to_svg(bpmn_path: Path, svg_path: Path) -> None:
    tree = ET.parse(bpmn_path)
    root = tree.getroot()

    ns = {
        "bpmn": "http://www.omg.org/spec/BPMN/20100524/MODEL",
        "bpmndi": "http://www.omg.org/spec/BPMN/20100524/DI",
        "dc": "http://www.omg.org/spec/DD/20100524/DC",
    }

def sanitize_svg(svg_path: Path) -> None:
    """
    Usuń jednostkę 'deg' z wyrażeń rotate(...) w pliku SVG,
    np. 'rotate(45deg)' -> 'rotate(45)', aby svglib mogło je sparsować.
    """
    text = svg_path.read_text(encoding="utf-8")
    new = re.sub(r'rotate\(\s*([+-]?\d+(?:\.\d+)?)\s*deg\s*\)', r'rotate(\1)', text, flags=re.IGNORECASE)
    if new != text:
        svg_path.write_text(new, encoding="utf-8")
        logging.debug("Sanitized rotate(...deg) in %s", svg_path)

def svg_to_pdf(svg_path: Path, pdf_path: Path) -> None:
    """
    Sanitize SVG then convert to PDF using svglib + reportlab.
    """
    sanitize_svg(svg_path)
    drawing = svg2rlg(str(svg_path))
    renderPDF.drawToFile(drawing, str(pdf_path))


def process_all(bpmn_dir: Path, out_dir: Path) -> int:
    ensure_dirs(out_dir)
    processed = 0
    for bpmn_file in sorted(bpmn_dir.glob("*.bpmn")):
        base_name = bpmn_file.stem
        svg_file = out_dir / f"{base_name}.svg"
        pdf_file = out_dir / f"{base_name}.pdf"

        try:
            bpmn_to_svg(bpmn_file, svg_file)
        except Exception as e:
            logging.error("Błąd przy generowaniu SVG dla %s: %s", bpmn_file, e)
            continue

        try:
            svg_to_pdf(svg_file, pdf_file)
        except Exception as e:
            logging.error("Błąd przy konwersji SVG->PDF dla %s: %s", svg_file, e)
            continue

        logging.info("OK: %s -> %s -> %s", bpmn_file.name, svg_file.name, pdf_file.name)
        processed += 1


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Konwertuj pliki BPMN -> SVG -> PDF (czysto Python).")
    parser.add_argument("--bpmn-dir", type=Path, default=BPMN_DIR, help="Folder ze źródłowymi plikami BPMN.")
    parser.add_argument("--out-dir", type=Path, default=EXPORT_DIR, help="Folder docelowy eksportów.")
    parser.add_argument("--verbose", action="store_true", help="Włącz logowanie INFO.")
    args = parser.parse_args()

    logging.basicConfig(level=logging.INFO if args.verbose else logging.WARNING, format="%(levelname)s: %(message)s")

    if not args.bpmn_dir.exists():
        logging.error("Folder źródłowy nie istnieje: %s", args.bpmn_dir)
        raise SystemExit(1)

    try:
        count = process_all(args.bpmn_dir, args.out_dir)
    except Exception:
        logging.exception("Nieoczekiwany błąd podczas przetwarzania.")
        raise SystemExit(2)

    logging.info("Przetworzono plików: %d", count)
    print(f"Przetworzono plików: {count}")
