# AGENTS.md

Guidance for AI agents (and anyone scripting work) in this repository.

## Repo at a glance

- `map1/` … `map4/` are standalone demo pages. Each `mapN/` folder contains its own copy of the libraries and data it loads, so it can be copied/deployed on its own.
- `map1.html` loads MapLibre from the unpkg CDN. `map2/` uses MapLibre v5.7.3. `map3/` and `map4/` use MapLibre v6.14.0; `map4/` additionally wires in PMTiles.
- Root-level `local1-versatiles/` is the original reference copy of the shared style/sprite/glyph data. The Maplibre and PMTiles libraries live only inside the `mapN/` folders that load them.
- README screenshots live in `img/`.
- `vector-tiles/generate-vector-tiles.sh` builds the vector tiles. Generated archives (`india.pmtiles`, `.pbf` extracts, tile directories) are large and are not committed.

## Do not run browser-side testing without asking

- **Do not** launch headless or automated browsers (Chromium, Firefox, Playwright, Puppeteer, Selenium, …), capture screenshots, or run WebGL / map-rendering checks unless the user explicitly asks for it in the current conversation.
- The maintainer verifies the maps in a real browser. Headless runs in this environment are unreliable (sandbox, GPU and network limits) and easy to misread, and they waste time.
- Do not install browser-automation packages or download browser binaries without asking first.
- If a browser check seems genuinely necessary, stop and ask the user what needs to be validated.

## Verification that is fine

- Shell syntax: `bash -n`.
- JS syntax without execution: `node --check file.mjs`.
- Serve the repo with `python3 -m http.server` and use `curl` to confirm that referenced assets return 200 and that in-page paths match files on disk.
- Markdown link checks, `git status` / `git diff` review.
- Static file comparisons (`cmp`, `diff -r`) when copying dependencies between folders.

## Other conventions

- Keep each `mapN/` folder self-contained; duplicating libraries and `local1-versatiles/` across folders is intentional.
- Don't delete the root `local1-versatiles/` reference copy, or upgrade/downgrade a map's library version, without asking.
- Don't run heavy jobs (tile generation, Docker builds, full OSM downloads) without asking.
- Keep large/generated files out of git; `india.pmtiles` is already in `.gitignore`.
