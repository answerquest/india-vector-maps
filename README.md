# india-vector-maps


## Introduction
An open source project to pump out maps (web pages) and boilerplate code with made-for-India vector styles, thematic maps, multilingual, whatnot.

This is relatively new tech; traditionally if we wanted to customize something, we had to buy heavy servers pre-rendering images as map tiles and v.complicated to setup + maintain.

Now thanks to vector map tech, we can use the same common source data, but fine-tune the rendering to make our  own "flavours". You can make a map with labels in your language. You can make thematic maps that display selected places more prominently, like a map for education, or transport. All this by editing a json file! 

## How to get started, for non-coders
- Check out the pinned live map
- Share your ideas and inputs in the Discussion section

## How to get started, for coders
- Download the repo
- Run it on local system by starting a simple web server from the repo root. Quick python way: `python3 -m http.server`
- Open the map you want to work on:
  - http://localhost:8000/map1/map1.html
  - http://localhost:8000/map2/map2.html
  - http://localhost:8000/map3/map3.html
  - http://localhost:8000/map4/map4.html
- Tinker -> Refresh browser -> Repeat

Each map lives in its own self-contained folder, so you can also `cd` into that folder and serve it directly (`cd map2 && python3 -m http.server`) — but serving from the repo root keeps all four available at once.

## Repository layout

Every `map{N}/` folder is **self-contained** and holds its own copy of the libraries and data it needs, so each folder can be copied/deployed independently:

```
india-vector-maps/
├── map1/
│   └── map1.html                  # loads maplibre from unpkg CDN, no local deps
├── map2/
│   ├── map2.html
│   ├── maplibre-gl-5.7.3/         # JS + CSS
│   └── local1-versatiles/         # style json, sprites, glyphs (~78 MB, mostly glyphs)
├── map3/
│   ├── map3.html
│   ├── maplibre-gl-6.10.0/        # .mjs + .css + shared chunk + worker
│   └── local1-versatiles/
├── map4/
│   ├── map4.html
│   ├── maplibre-gl-6.10.0/
│   ├── local1-versatiles/         # includes colorful_style_pmtiles.json
│   └── pmtiles-4.5.0/             # PMTiles JS library
├── maplibre-gl-5.7.3/             # original shared copy (also inside map2/)
├── maplibre-gl-6.10.0/            # original shared copy (also inside map3/ and map4/)
├── pmtiles-4.5.0/                 # original shared copy (also inside map4/)
├── local1-versatiles/             # original shared copy (also inside map2/, map3/ and map4/)
├── vector-tiles/                  # PMTiles archive + generator script (served separately, see Vector tiles self-hosting)
├── maplibre-upgrade-guide.md
└── README.md
```

The folders at the repo root are the **originals** and are kept as-is. Each map page loads only the copies that sit inside its own folder (via paths relative to `map{N}/map{N}.html`), so the root copies are reference material and do not affect the maps. The same libraries and the same `local1-versatiles` data therefore appear several times; that is intentional: it keeps each map folder deployable on its own. If you edit a style json or sprite, copy the change across the folders you care about (or deploy only the folder you edited).

## Customize style using Maputnik editor
- Open the respective style json in this repo, like [map2/local1-versatiles/colorful_style.json](map2/local1-versatiles/colorful_style.json) : click "Raw" button to get the raw content in browser, and copy the browser URL 
- Note the style json exists once per map folder (`map2/`, `map3/`, `map4/`) and a root `local1-versatiles/` copy is kept as reference; edit the copy inside the map folder whose page you are working on.
- Open https://maplibre.org/maputnik/
- Click "Open" in top menu
- Paste the copied URL under "Load from URL" and proceed
- You should now see the map loading on right (might take time), and on left a huge editable form with several sections
- Make changes on left and see output on right
- Note: it gets v.slow sometimes. Maybe loading restrictions. It's an open-source tool, so you could check out the [Maputnik repo](https://github.com/maplibre/maputnik), download and run it from your local.
- When you're happy with the changes, save your work as a new json file.
- Make a new map html with that, and PR it here! (Or publish it at your side, your choice)


## Some goals to shoot for

- Displaying approved-for-India boundaries through controlling visibility for those specific borders' shapes
- Indian language maps where main title is in chosen language, and defaults to English if not available
- Thematic maps where a focus class of POIs, shapes get displayed more prominently (ie, visible at lower zoom levels) while other things are downplayed to prevent overcrowding
- Solving sprites issues: Getting fixed sprite URLs that we have complete control over and can customize
- Getting the right fonts for Indian languages that don't break apart in rendering
- Making visible new kinds of POIs that matter to maps in India but have been sidelined in international maps 


# Map Versions Documentation

Each map is a standalone folder. To publish one, **copy that whole folder** to your web host; the page URL will then be `{BASEURL}/map{N}/map{N}.html`. Each map page has a `BASEURL` variable near the top of its script — set it to the folder URL on your host (e.g. `https://example.com/india-vector-maps/map2`). When the page is opened from anywhere else (like your local server), `BASEURL` is replaced at runtime with the URL of the folder the page is being served from, so local runs need no edits.

## map1/ — `map1.html`

It's a very basic, no-frills map using the Maplibre JS library.

**What to copy:** just the [map1](map1) folder. It has no local dependency files — the Maplibre JS and CSS are loaded from the unpkg CDN.

References the CDNs only.

DISCLAIMER: This map has zero intervention for Indianization done on it; hence all disputed borders are shown. Do not use in production. It's there as minimum working code to use as template to build from.


## map2/ — `map2.html`

**What to copy:** the whole [map2](map2) folder — `map2.html` plus `maplibre-gl-5.7.3/` and `local1-versatiles/` (about 79 MB in total). Nothing outside `map2/` is needed.

**Self-hosting:**
- All the dependencies : style json, sprites json & png, glyphs : Are localized and stored in [`map2/local1-versatiles`](map2/local1-versatiles), about 78 MB in total, majority of it being the glyphs.
- The JS, CSS are copied from the CDNs as of v5.7.3 (copied on 2025-09-22) and kept in [`map2/maplibre-gl-5.7.3`](map2/maplibre-gl-5.7.3).
- Glyphs sourced from https://github.com/versatiles-org/versatiles-fonts/releases : downloaded the fonts.tar.gz, and copied over folders of noto_sans_regular and noto_sans_bold.
- Style json: colorful_style.json is copied from https://tiles.versatiles.org/assets/styles/colorful/style.json (copied on 2025-09-22) and then some changes have been made to it.
- When running in local, if a resource url starts with this repo's deployment url, then it is replaced by the local url so that you can run the map in local with the local sprites and glyphs loaded. This is done using `transformRequest` option in map declaration and is adapted from (but later heavily changed) https://github.com/mapbox/mapbox-gl-js/pull/9225#issuecomment-578089885
- Sprites .png and .json sourced from path https://tiles.versatiles.org/assets/sprites/basics/sprites given in the style json (copied on 2025-09-22).

**Note:** In case you're deploying this map on your own site, pls change the value of `BASEURL` in [map2.html](map2/map2.html) to your hosted folder location accordingly (e.g. `https://your.site/india-vector-maps/map2`).

**Indianizing the map:**
- Incorporated changes documented on https://github.com/osm-in/osm-in.github.io/issues/87#issuecomment-3180638831 to hide disputed boundaries, add Indian state boundaries.


**Other features:**
- Added navigation control including a compass button that shows the direction and tilt of the map (right-click + drag to tilt/rotate) , and resets on clicking.
- Added fullscreen control button.
- Made the map render on a globe (zoom out to see it) using setProjection function. Source: https://maplibre.org/maplibre-gl-js/docs/examples/display-a-globe-with-a-vector-map/ .

**Jump links to what we can edit here:**
- the vector style json that controls how things are rendered: [map2/local1-versatiles/colorful_style.json](map2/local1-versatiles/colorful_style.json) 
- Sprites (Icons) for POIs: [map2/local1-versatiles/assets/sprites/basics](map2/local1-versatiles/assets/sprites/basics)
- The map HTML and JS: [map2/map2.html](map2/map2.html)

**Other info**
- Vector tile source URL being used: `https://vector.openstreetmap.org/shortbread_v1/{z}/{x}/{y}.mvt` . It was `https://tiles.versatiles.org/tiles/osm/{z}/{x}/{y}` earlier.
- This is specified in the style json used by the map, not in the main JS directly,


## map3/ — `map3.html`

An upgrade of map2.html to Maplibre GL JS v6.10.0. The map features, controls, globe projection and the style json are the same as map2.html; the changes are the library's major-version breaking changes, plus a few state-boundary rendering fixes.

**What to copy:** the whole [map3](map3) folder — `map3.html` plus `maplibre-gl-6.10.0/` and `local1-versatiles/` (about 80 MB in total). Nothing outside `map3/` is needed.

**Upgrading the library from v5.7.3 to v6.10.0 (breaking changes):**
- v6 is ESM-only: the old UMD `maplibre-gl.js` script bundle no longer exists. The library is loaded as a module instead: `<script type="module">` with `import * as maplibregl from './maplibre-gl-6.10.0/maplibre-gl-6.10.0.mjs'`. The namespace import (`import * as maplibregl`) replaces the earlier default import.
- v6 requires WebGL2; WebGL1 support has been removed. Older browsers/devices without WebGL2 will fail on `new maplibregl.Map(...)`.
- The rest of the map code (`new Map({...})`, `setStyle(..., {transformStyle})`, `transformRequest`, `FullscreenControl`, `NavigationControl`, `Marker`, `style.load` + `setProjection({type: 'globe'})`) is unchanged and still valid in v6.
- Relative paths in the style json (sprite / glyphs / sources) are still not supported natively, so the existing `transformRequest` / `transformStyle` BASEURL rewrite continues to be used.
- Migration reference: https://github.com/maplibre/maplibre-gl-js/blob/main/docs/guides/v5-to-v6-migration-guide.md

**Self-hosting:**
- The Maplibre library files are kept inside this map's own folder, so `map3/` is self-contained:
  - [map3/maplibre-gl-6.10.0](map3/maplibre-gl-6.10.0) : `maplibre-gl-6.10.0.mjs` and `maplibre-gl-6.10.0.css`, plus `maplibre-gl-shared.mjs` (shared code chunk) and `maplibre-gl-worker.mjs` (web worker) which the v6 ESM bundle loads at runtime.
- The v6 module resolves its worker and shared chunk relative to itself (via `new URL('./maplibre-gl-worker.mjs', import.meta.url)`), so those two files must stay in the same folder as the `.mjs`.
- `map3/local1-versatiles` holds the versatiles data : style json, sprites, glyphs.
- (map2.html keeps its own copy of the v5 library in `map2/maplibre-gl-5.7.3`.)

**Indianizing the map (style json refinements):**
- The `bhuvan-states` source `maxzoom` is set to 9, its actual native maximum zoom. 
- But the data from there is fetched and rendered on map all the way to map's max zoom. 
- The boundary lines were made more prominent.
- The versatiles-shortbread state-level boundary layers (`boundary-state:outline` and `boundary-state`) are hidden with `"visibility": "none"`, so only the `bhuvan-states` boundaries are shown for states. Country-level boundaries are unaffected.

**Overzoom fix (v6-specific):**
- v6 added an experimental `zoomLevelsToOverscale` option (default 4). For vector sources it fetches native tiles up to `max(map.maxZoom - 4, source.maxzoom)`, so a source with `maxzoom: 9` kept requesting non-existent z10–z16 tiles, making the boundaries disappear as soon as the map zoom went beyond 9.
- Setting `zoomLevelsToOverscale: undefined` in the Map options restores the v5 behavior: fetch only up to `source.maxzoom` (9), then overzoom those tiles up to the map's max zoom (20).

**Note:** In case you're deploying this map on your own site, pls change the value of `BASEURL` in [map3.html](map3/map3.html) to your hosted folder location accordingly (e.g. `https://your.site/india-vector-maps/map3`).

**Jump links to what we can edit here:**
- the vector style json that controls how things are rendered: [map3/local1-versatiles/colorful_style.json](map3/local1-versatiles/colorful_style.json)
- Sprites (Icons) for POIs: [map3/local1-versatiles/assets/sprites/basics](map3/local1-versatiles/assets/sprites/basics)
- The map HTML and JS: [map3/map3.html](map3/map3.html)
- The Maplibre v6 library files: [map3/maplibre-gl-6.10.0](map3/maplibre-gl-6.10.0)


## map4/ — `map4.html`

An evolution of map3.html where the vector tiles are served from a **single self-hosted [PMTiles](https://docs.protomaps.com/pmtiles/) archive** instead of the versatiles/osm tile server. This makes the whole map self-contained: one `.pmtiles` file can be dropped on any static host and served over plain HTTP.

**What to copy:** the whole [map4](map4) folder — `map4.html` plus `maplibre-gl-6.10.0/`, `local1-versatiles/` and `pmtiles-4.5.0/` (about 80 MB in total). The `.pmtiles` archive itself is **not** inside the folder; it is served separately from [vector-tiles](vector-tiles) (or any host) — see [Vector tiles self-hosting](#vector-tiles-self-hosting).

**How PMTiles is wired in:**
- The [PMTiles JS library](map4/pmtiles-4.5.0/pmtiles.js) is loaded with a plain `<script>` tag before the module.
- A `pmtiles://` protocol handler is registered with MapLibre: `new pmtiles.Protocol()` + `maplibregl.addProtocol('pmtiles', protocol.tile)`. MapLibre then reads the archive through this handler.
- The style json [map4/local1-versatiles/colorful_style_pmtiles.json](map4/local1-versatiles/colorful_style_pmtiles.json) defines the `india-pmtiles` vector source with a placeholder `pmtiles://https://example.com/india.pmtiles` URL.
- At runtime map4.html overwrites that URL with `PMTILES_URL` (set near the top of the script). Point it at your public `.pmtiles` file, e.g. `https://server.nikhilvj.co.in/india.pmtiles`.
- The archive in [vector-tiles/india.pmtiles](vector-tiles/india.pmtiles) was generated with [vector-tiles/generate-vector-tiles.sh](vector-tiles/generate-vector-tiles.sh), which also attempts to optimize it by clustering via the `pmtiles` CLI (see the known issue in [Vector tiles self-hosting](#vector-tiles-self-hosting)).
- Everything else (BASEURL substitution for glyphs/sprites, globe projection, controls) is the same as map3.html.

**Note:** In case you're deploying this map on your own site, pls change the value of `BASEURL` and `PMTILES_URL` in [map4.html](map4/map4.html) to your hosted locations accordingly.

**Jump links to what we can edit here:**
- the vector style json that controls how things are rendered: [map4/local1-versatiles/colorful_style_pmtiles.json](map4/local1-versatiles/colorful_style_pmtiles.json)
- Sprites (Icons) for POIs: [map4/local1-versatiles/assets/sprites/basics](map4/local1-versatiles/assets/sprites/basics)
- The map HTML and JS: [map4/map4.html](map4/map4.html)
- The PMTiles library: [map4/pmtiles-4.5.0](map4/pmtiles-4.5.0)
- The `.pmtiles` archive and generator script: [vector-tiles](vector-tiles)


# Vector tiles self-hosting

All of these maps need **vector tile data**. map1–map3 read it from public servers; map4 reads it from a self-hosted archive. The data can be generated locally from an OpenStreetMap extract with [vector-tiles/generate-vector-tiles.sh](vector-tiles/generate-vector-tiles.sh), which can write it in three different shapes. This section explains what the script does, what each output is good for, and how to host the result for map4.

## What `generate-vector-tiles.sh` does

Run the script from inside the `vector-tiles/` folder — it writes its downloads and output into the current directory. In order, it:

1. **Downloads / updates the OSM extract.** `india.pbf` from Geofabrik (`OSM_URL`), resumable and multi-connection via aria2c. If a local `india.pbf` is already at least as new as the server's `Last-Modified` timestamp, the download is skipped.
2. **Optionally downloads extra shapefiles** (`DOWNLOAD_EXTRA_DATA="yes"`): coastline water polygons from OSMData, plus Natural Earth urban areas, glaciers and Antarctic ice shelves. tilemaker uses these to render water / landcover at low zoom levels. They are cached in `coastline/` and `landcover/`, so they are downloaded only once.
3. **Runs tilemaker in Docker** (`ghcr.io/systemed/tilemaker:master`) against the OpenMapTiles profile (`config-openmaptiles.json` + `process-openmaptiles.lua`). The container is capped by `CPUS` and `MAX_RAM`, tilemaker is given `THREADS`, and setting `STORE_DIR` makes it use an on-disk store instead of keeping everything in RAM (useful for big extracts).
4. **Writes the tiles** in the format selected by `OUTPUT_FORMAT`.
5. **Optionally optimizes a `.pmtiles` archive** by running `pmtiles cluster`, using a native `pmtiles` binary if present and the `protomaps/go-pmtiles` Docker image otherwise. Only applies when `OUTPUT_FORMAT="pmtiles"` and `OPTIMIZE_PMTILES="yes"`.

**Prerequisites:** Docker (for tilemaker, and for the pmtiles CLI if no native binary), `aria2c` for the downloads, and any one of `unzip` / `7z` / `7za` / `bsdtar` / `python3` for the extra shapefiles.

### Configuration knobs (top of the script)

| Variable | Default | What it controls |
| --- | --- | --- |
| `OSM_URL` | Geofabrik `india-latest.osm.pbf` | Extract to download |
| `OSM_PBF` | `india.pbf` | Local filename for the extract |
| `OUTPUT_FORMAT` | `pmtiles` | `pbf`, `mbtiles` or `pmtiles` — see below |
| `OUTPUT_DIR` | `tiles` | Output folder, only for `pbf` |
| `OUTPUT_NAME` | `india` | Base name of the single-file outputs |
| `CPUS` | `14` | Hard CPU limit for the tilemaker container |
| `MAX_RAM` | `50g` | Hard RAM limit for the tilemaker container |
| `THREADS` | same as `CPUS` | tilemaker worker threads |
| `STORE_DIR` | empty (RAM) | On-disk temp store for tilemaker |
| `DOWNLOAD_EXTRA_DATA` | `yes` | Fetch coastline / landcover shapefiles |
| `FULL_REGENERATE` | `no` | Delete previous output before generating |
| `OPTIMIZE_PMTILES` | `yes` | Run `pmtiles cluster` on the new archive |
| `PMTILES_DOCKER_IMAGE` | `protomaps/go-pmtiles` | Image used for the pmtiles CLI |

## Output options

`OUTPUT_FORMAT` picks one of three shapes for the generated tiles. They hold the same data; the difference is how you serve and consume them.

### `pbf` — a folder of z/x/y tiles

- `OUTPUT_FORMAT="pbf"` writes `{z}/{x}/{y}.pbf` files into `OUTPUT_DIR` (default `tiles/`), e.g. `tiles/5/18/11.pbf`.
- It is just a directory tree of static files: any static file server or CDN can serve it, and every tile is cached on its own. Good for debugging individual tiles and for setups that front the tiles with a cache.
- Serve it locally with `python3 -m http.server 8000 --directory tiles` (or `npx serve tiles`) and point MapLibre straight at it:

```js
map.addSource('osm', {
  type: 'vector',
  tiles: ['http://localhost:8000/{z}/{x}/{y}.pbf'],
  minzoom: 0,
  maxzoom: 14
});
```

- The cost is scale: a country-sized extract means a very large number of small files, which is slow to copy/upload and hard on filesystem inode limits, and there is no single portable artifact to hand around.

### `mbtiles` — one SQLite file

- `OUTPUT_FORMAT="mbtiles"` writes `OUTPUT_NAME.mbtiles` (default `india.mbtiles`) in the current folder.
- It is a compact single file, good for archiving and for feeding desktop/GIS tools. Browsers cannot read it directly, so it needs an MBTiles-capable tile server (or a conversion to PMTiles):

```bash
docker run --rm -v "$(pwd)":/data -p 8080:8080 maptiler/tileserver-gl india.mbtiles
```

- Useful when you already run a tile server; not usable as a plain static file behind the map page.

### `pmtiles` — one archive the browser reads directly

- `OUTPUT_FORMAT="pmtiles"` writes `OUTPUT_NAME.pmtiles` (default `india.pmtiles`) in the current folder. This is the format map4.html uses, and the archive in [vector-tiles/india.pmtiles](vector-tiles/india.pmtiles) is one such output.
- A PMTiles client fetches individual tiles out of the archive with HTTP `Range` requests, so in principle you **can** just drop the `.pmtiles` file on any static host and point `PMTILES_URL` at it.
- **But be careful with bandwidth:** this is one large file (~200 MB for the India extract), and the client keeps making small range requests against it. If a server ignores `Range` and answers `200 OK` with the whole file, or if the `206 Partial Content` responses are not cached, the same large payload can be re-downloaded again and again — on every visit, by every client, and by any crawler or chat/link preview that happens to touch the URL. On a metered host that turns into real cost for no visible benefit. That is why the server setup below is strongly advised.

**Wiring it into the map:** set `PMTILES_URL` in [map4/map4.html](map4/map4.html):

```js
const PMTILES_URL = `https://your.domain.com/india.pmtiles`;
```

The archive does not have to live next to the page. The repo keeps it in [vector-tiles/india.pmtiles](vector-tiles/india.pmtiles) and points at it with a full URL, so only `map4/` needs to be copied to deploy the page. If you do want a fully self-contained offline copy, put `india.pmtiles` inside `map4/` and set `PMTILES_URL = 'india.pmtiles'` (a relative path resolves against the page) — but note that many static hosts (e.g. GitHub Pages, 100 MB per file) will reject a file that size, so keep it off the repo-backed deployment.

#### Recommended server setup (Range + CORS)

- PMTiles clients read the archive with HTTP **Range requests** (to fetch individual tiles), so the host must support `Range` and return `206 Partial Content`. Most static servers (including Caddy's `file_server`) do this.
- Because the `.pmtiles` file is typically served from a **different origin** than the map page, the host must also send **CORS headers**, otherwise the fetch fails with a CORS error. The response headers (including `Content-Range`) must be exposed to the browser.
- With [Caddy](https://caddyserver.com/) this is done with the `header` directive plus a `respond` for preflight `OPTIONS`:

```caddyfile
your.domain.com {
	root * /usr/share/caddy

	# Allow all CORS
	header {
		Access-Control-Allow-Origin  *
		Access-Control-Allow-Methods "GET, HEAD, OPTIONS"
		Access-Control-Allow-Headers "*"
		Access-Control-Expose-Headers "Content-Range, Content-Length, Accept-Ranges"
		Access-Control-Max-Age 86400
	}

	# Answer CORS preflight directly
	@options method OPTIONS
	respond @options 204

	file_server
}
```

- The `header` block applies to every response, including the `206 Partial Content` range responses, so `Content-Range` is exposed and MapLibre can read the tiles.
- After editing the Caddyfile, validate and reload Caddy:

```bash
# check the config for syntax errors
caddy validate --config /etc/caddy/Caddyfile

# (optional) auto-format the Caddyfile
caddy fmt --overwrite /etc/caddy/Caddyfile

# apply the new config without dropping connections
caddy reload --config /etc/caddy/Caddyfile
```

#### Known issue: the first load can still pull a large chunk

- A PMTiles client starts with a 16 KiB range request (`bytes=0-16383`) covering the header and root directory. `tilemaker` writes an *unclustered* archive, in which almost every tile entry sits in a **single huge leaf directory** (~4.6 MB for the India extract). Before it can resolve the first tile, the client has to fetch that whole leaf — the multi-MB blocking request seen on page load.
- Those responses arrive as `206 Partial Content`, which browsers usually do not cache across page loads, so the same bytes are fetched again on the next visit.
- **We have attempted to solve this by clustering:** `OPTIMIZE_PMTILES="yes"` runs `pmtiles cluster`, which rewrites the directory tree as many smaller leaves, and it can also be applied to an existing archive in place:

```bash
# native binary
pmtiles cluster india.pmtiles

# or Docker (input must be an unclustered archive)
docker run --rm -v "$(pwd)":/data protomaps/go-pmtiles cluster /data/india.pmtiles

# inspect the resulting layout (root / leaf / metadata sizes)
pmtiles show india.pmtiles
```

- **Status: not confirmed resolved.** Testing so far has not shown the clustered archive actually bringing the first-load transfer down to what the smaller directory leaves should imply, so treat this as a known open issue. Further testing is needed: compare first-load and repeat-visit byte counts for clustered vs unclustered archives, and check how the chosen host actually answers the range requests.
- Mitigations already in place: `metadata: false` in [map4.html](map4/map4.html) (the archive JSON metadata is never fetched) and a hard-coded centre/zoom (the map does not wait for archive metadata).
- Options still worth testing for repeat visits: a Z/X/Y proxy in front of the archive (`pmtiles serve`, a Caddy `pmtiles_proxy`, a Cloudflare Worker, etc.) so the browser sees ordinary, cacheable tile URLs instead of range requests against one big file.
