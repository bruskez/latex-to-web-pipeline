# LaTeX to Web Pipeline (LaTeXML-based)

## Overview

This project demonstrates a **clean, reproducible workflow** for converting LaTeX documents into **web-friendly HTML representations**, with support for **navigation, versioning, and change tracking**.

It enables the ingestion, processing, and display of LaTeX content in formats suited for online browsing and AI-assisted use.

## Project Goals

* Convert LaTeX documents into HTML using semantic tools
* Preserve document structure (sections, subsections)
* Enable navigable web output with stable section identifiers
* Track changes from LaTeX sources to generated web documents
* Lay the foundation for automated ingestion pipelines

## Repository Structure

```text
src/        # LaTeX source documents and local image assets
tools/      # Processing scripts (HTML post-processing)
site/       # Generated web output (sample document)
docs/       # Notes and documentation
```

## Phase 0 — Project Initialization

The project starts with a clean Linux environment, Git version control, and a minimal directory structure ensuring reproducibility and maintainability.

## Phase 1 — LaTeX Source Documents

LaTeX documents are organized in individual directories under src/, with images stored alongside each document.

Example:

```text
src/aamini/
  ├── aamini.tex
  └── images/
```

This structure supports multi-document ingestion and avoids resource conflicts.

## Phase 2 — LaTeX to HTML Conversion

LaTeXML is used to convert LaTeX sources to HTML via a dedicated ingestion script
(`tools/build.sh`):

- mathematical content is preserved
- document structure is retained
- a web-oriented representation is generated
- multiple documents are processed in batch with per-document output and logs

## Phase 3 — HTML Post-processing and Navigation

Custom post-processing script (`tools/postprocess_html.py`) enhances the raw HTML by:

* assigning stable, readable identifiers to section headings
* generating a table of contents
* producing a navigable HTML document (`index.nav.html`)

This step decouples semantic conversion from presentation logic.

## Phase 4 — Versioning and Change Tracking

Git tracks changes in the LaTeX source and corresponding updates in the web output. This demonstrates end-to-end traceability from LaTeX edits to their web representation.

## Phase 5 —  Automation and Batch Ingestion

The project includes an automated pipeline to process **multiple LaTeX documents** in batch mode. Simply place documents under `src/<document_name>/` and run:

```bash
./tools/build_all.sh
```

The pipeline generates structured web output, organizes images, and writes detailed logs.

## Logging and Reproducibility

Logs are generated for each document, allowing inspection of warnings or errors. The process is deterministic: the same LaTeX sources will always reproduce the same web output.

## AI / Search Readiness
The pipeline produces structured HTML with stable section identifiers, enabling extensions such as semantic search, document chunking, and AI-assisted exploration.

For detailed AI/search feasibility, check `docs/ai_search_feasibility.md`.

## Notes

The project is developed and tested in a Linux environment using standard open-source tools.
