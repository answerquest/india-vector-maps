# india-vector-maps

An open source project to pump out maps (web pages) and boilerplate code with made-for-India vector styles, thematic maps, multilingual, whatnot.


The contents of folders versatiles-sprites/ and versatiles-styles/
are from the repo: https://github.com/versatiles-org/versatiles-style/releases/tag/v4.4.1

Starting web page: map1.html

It's a very basic, no-frills map using the Maplibre JS library.

## Some goals to shoot for

- Displaying approved-for-India boundaries through controlling visibility for those specific borders' shapes
- Indian language maps where main title is in chosen language, and defaults to English if not available
- Thematic maps where a focus class of POIs, shapes get displayed more prominently (ie, visible at lower zoom levels) while other things are downplayed to prevent overcrowding
- Solving sprites issues: Getting fixed sprite URLs that we have complete control over and can customize
- Getting the right fonts for Indian languages that don't break apart in rendering
- Making visible new kinds of POIs that matter to maps in India but have been sidelined in international maps 


## map1.html 

It's a very basic, no-frills map using the Maplibre JS library.

References the CDNs only.


## map2.html

**Self-hosting:**
- All the dependencies : style json, sprites json & png, glyphs : Are localized and stored in "local1-versatiles" folder, about 80MB in total, majority of it being the glyphs.
- The JS, CSS are copied from the CDNs as of v5.7.3 (copied on 2025-09-22).
- Glyphs sourced from https://github.com/versatiles-org/versatiles-fonts/releases : downloaded the fonts.tar.gz, and copied over folders of noto_sans_regular and noto_sans_bold.
- Style json: colorful_style.json is copied from https://tiles.versatiles.org/assets/styles/colorful/style.json (copied on 2025-09-22) and then some changes have been made to it.
- Got code to how to make the script work with locally sources assets using transformRequest from: https://github.com/mapbox/mapbox-gl-js/pull/9225#issuecomment-578089885
- Added `local://./` prefix on the glyphs and sprites paths; the transformRequest function then dynamically replaces it with correct absolute url.
- Having to do this because the lib doesn't tolerate simple local paths.
- Sprites .png and .json sourced from path https://tiles.versatiles.org/assets/sprites/basics/sprites given in the style json (copied on 2025-09-22).

**Indianizing the map:**
- Incorporated changes documented on https://github.com/osm-in/osm-in.github.io/issues/87#issuecomment-3180638831 to hide disputed boundaries, add Indian state boundaries.


**Other features:**
- Added navigation control including a compass button that shows the direction and tilt of the map (right-click + drag to tilt/rotate) , and resets on clicking.
- Added fullscreen control button.
- Made the map render on a globe (zoom out to see it) using setProjection function. Source: https://maplibre.org/maplibre-gl-js/docs/examples/display-a-globe-with-a-vector-map/ .

