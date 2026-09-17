From Grok.com

**For a simple 2D vector-tile map like yours (no terrain/3D tilting dependence in core logic), the main v5 → v6 breaking changes that matter are distribution/loading and a few API/behavior shifts. Most of your Map/Marker/Control/`setStyle`/`transformRequest` usage stays compatible.**

### Key breaking changes (v5 → v6, relevant to your case)

From the official [v5-to-v6 migration guide](https://github.com/maplibre/maplibre-gl-js/blob/main/docs/guides/v5-to-v6-migration-guide.md) and CHANGELOG:

1. **ESM-only distribution (biggest practical break)**  
   - No more UMD/`maplibre-gl.js` or CSP-specific bundles. Bundle is now `maplibre-gl.mjs` (+ worker).  
   - `<script src="...maplibre-gl.js">` → must become:
     ```html
     <script type="module">
       import * as maplibregl from 'https://unpkg.com/maplibre-gl@^6.10.0/dist/maplibre-gl.mjs';
       // ... your code using maplibregl
     </script>
     ```
   - Default import (`import maplibregl from 'maplibre-gl'`) → `import * as maplibregl from 'maplibre-gl'` (or named imports).  
   - Pin a version (e.g. `^6.10.0`); `@latest` can break silently across majors.  
   - Bundlers often still need a one-time `setWorkerUrl(...)` (see docs for Vite/webpack/etc.). CDN `<script type="module">` usually auto-detects the worker.

2. **WebGL2 required**  
   WebGL1 support removed. Modern browsers are fine; older devices/browsers without WebGL2 will throw `GPUInitializationError` on `new Map(...)`. Listen via `map.on('error', ...)` if needed.

3. **`styleimagemissing` no longer resolves images**  
   It is notify-only. Use `map.setMissingStyleImageResolver(...)` instead if you were supplying images in the old event handler. (Your code does not use this.)

4. **Nested GeoJSON properties**  
   Objects/arrays in feature properties are now real objects (not stringified). Remove any `JSON.parse` you were doing on them. (Irrelevant unless you query features with nested props.)

5. **`map.transform` removed**  
   Internal; use public Map/Camera APIs. (Your code does not touch it.)

6. **Other smaller / less relevant**  
   - Events are now classes (prefer checking `.type` over `instanceof`).  
   - `#pragma mapbox` → `#pragma maplibre` (shaders/custom layers).  
   - Experimental `zoomLevelsToOverscale` default changed (can set to `undefined` to restore old overscaling behavior).  
   - Icon scaling with offset disabled (render change).  
   - Light position interpolation, hash parsing edge cases, etc. — unlikely to affect a basic 2D vector map.  
   - Later 6.x releases (up to 6.10.0) are mostly features/fixes (sky in globe, performance, terrain/marker occlusion, complex-script text without RTL plugin, etc.). No further major API breaks for your pattern.

Your sample code’s core pieces (`new Map({container, center, zoom, hash, maxZoom, validateStyle, transformRequest})`, `map.setStyle(..., {transformStyle})`, `FullscreenControl` / `NavigationControl`, `Marker`, `style.load` + `setProjection({type: 'globe'})`) remain valid. Globe projection and the controls continue to work; the map itself is still fine as a 2D/mercator-or-globe viewer without terrain.

### Relative paths in style JSON (sprite / glyphs / sources)

**Still not supported natively.** The style spec and loader continue to require absolute URLs (scheme + authority + path). Relative paths throw (e.g. sprite normalization: “Invalid sprite URL … must be absolute. Modify style specification directly or use TransformStyleFunction…”).

- Issue [#182](https://github.com/maplibre/maplibre-gl-js/issues/182) (relative paths) remains open / enhancement.  
- Related notes confirm sprites/glyphs still need absolute URLs; some root-relative cases work for raster/glyphs/sprites but not reliably for vector tiles.  
- **Recommended approach (exactly what your code already does):** keep using `transformStyle` (and/or `transformRequest`) to rewrite relative/`BASEURL` placeholders to absolute URLs before the style is applied. The docs explicitly mention this pattern for relative sprite/glyphs/sources.

Your existing `transformRequest` + `transformStyle` that replace `"BASEURL"` will continue to work under v6; just ensure the resulting URLs are fully absolute after the rewrite.

### Practical migration steps for your snippet

1. Switch the library load to ESM (`type="module"` + import from `.mjs`, or npm named/namespace import).  
2. Keep `validateStyle: false` if you want (still available).  
3. Keep your `transformRequest` / `transformStyle` for the BASEURL rewrite — still the right way to handle non-absolute paths.  
4. Test WebGL2 availability and the globe projection if you rely on it.  
5. If you use a bundler, add the `setWorkerUrl` call once.

After those, the rest of the code should run essentially unchanged on 6.10.0. Full details are in the [migration guide](https://github.com/maplibre/maplibre-gl-js/blob/main/docs/guides/v5-to-v6-migration-guide.md) and the 6.0.0 + later CHANGELOG entries.
