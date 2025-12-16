# LaTeX to Web Pipeline (LaTeXML-based)

## Overview

This project demonstrates a **clean, reproducible workflow** for converting LaTeX documents into **web-friendly HTML representations**, with explicit support for **navigation, versioning, and change tracking**.

The goal is to explore how technical LaTeX documents can be ingested, processed, and exposed in formats suitable for online browsing and future search or AI-assisted use.

---

## Project Goals

* Convert LaTeX documents into HTML using semantic tools
* Preserve document structure (sections, subsections)
* Enable navigable web output with stable section identifiers
* Track changes from LaTeX sources to generated web documents
* Lay the foundation for automated ingestion pipelines

---

## Repository Structure

```text
src/        # LaTeX source documents and local image assets
tools/      # Processing scripts (HTML post-processing)
site/       # Generated web output (sample document)
docs/       # Notes and documentation
```

---

## Phase 0 — Project Initialization

The project starts from a clean Linux environment with:

* a minimal directory structure
* Git version control initialized
* a clear separation between sources, tools, and generated output

This ensures a reproducible and maintainable setup from the beginning.

---

## Phase 1 — LaTeX Source Documents

LaTeX documents are organized so that:

* each document lives in its own directory under `src/`
* image assets are stored locally alongside the document

Example:

```text
src/main/
  ├── main.tex
  └── images/
```

This structure supports multi-document ingestion and avoids resource conflicts.

---

## Phase 2 — LaTeX to HTML Conversion

The project uses **LaTeXML** to convert LaTeX sources into HTML:

* mathematical content is preserved
* document structure is retained
* a first web-oriented representation is generated

The raw HTML output is stored under `site/` and serves as the baseline for further processing.

---

## Phase 3 — HTML Post-processing and Navigation

A custom post-processing script (`tools/postprocess_html.py`) enhances the raw HTML by:

* assigning stable, readable identifiers to section headings
* generating a table of contents
* producing a navigable HTML document (`index.nav.html`)

This step decouples semantic conversion from presentation logic.

---

## Phase 4 — Versioning and Change Tracking

The project uses Git to track:

* LaTeX source changes
* corresponding updates in the generated HTML output

This demonstrates end-to-end traceability from document edits to their web representation, a key requirement for large technical documentation systems.

A sample navigable HTML output is available at:

```
site/main/index.nav.html
```

---

## Current Status

At this stage, the project provides:

* structured LaTeX sources
* HTML conversion via LaTeXML
* navigable web output
* clean Git history demonstrating document evolution

The next step is to automate the full ingestion process across multiple documents.

---

## Notes

The project is developed and tested in a Linux environment using standard open-source tools.

---

