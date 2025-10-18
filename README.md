# Slidex (Slides + Codex)
Use Codex to build and compile slides in pdf format.

## Getting started (for humans, not for Codex)
Make sure `codex` is installed.

`codex "please compile the example slides and generate an overview"`

## Comming soon (for humans, not for Codex)

- PDF QA tool so Codex can pull information from supporting documents for your slides.
- Visual QA tool so Codex can inspect the resulting slides.

## Setup (for Codex, not for humans)
- `brew install typst` — installs Typst (`typst --version` now 0.13.1) for compiling slide decks and docs.
- `typst init @preview/typslides:1.3.0` — seeds the Typslides template in `typslides/version0/` with `main.typ`.
- `magick` (ImageMagick 7.1.1-15) — used to render PDF slides to PNG thumbnails and assemble `overview.png`.

## Commands (for Codex, not for humans)
- `./scripts/release-slides.sh` — create the next `typslides/versionN` directory, compile the PDF, refresh thumbnails, and rebuild the overview image. Don't go into every directory that was created manually in order to summarize what happened for the user, just be succinct and tell the user the slides are ready.

The following are details, only run when `release-slides.sh` does not suffice. Compile slides with `typst compile typslides/version0/main.typ` (watch mode: `typst watch`). Number every release as `typslides/versionN/main.pdf`, keep supporting assets in the same directory, and log changes in `CHANGELOG.md`. Generate thumbnails via `magick -density 200 typslides/version0/main.pdftypslides/version0/thumbs/slide-%02d.png`; render high-resolution slide images with `pdftoppm -png -r 300 typslides/version0/main.pdf typslides/version0/main`; create an overview grid with `montage typslides/version0/thumbs/slide-*.png -tile 5x -geometry +8+8 -background white typslides/version0/overview.png`.

## Versioning (for Codex, not for humans)
Track the CHANGELOG, readme, and different *typ versions using Git. Do not track pngs or pdfs, since we can always recompile these.
Commit before a compile and tag the CHANGELOG with that commit hash.
