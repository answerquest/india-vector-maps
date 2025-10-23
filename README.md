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
- Run it on local system by starting a simple web server. Quick python way: `python3 -m http.server`
- Open `http://localhost:8000` or the mentioned url in your browser 
- Tinker -> Refresh browser -> Repeat

## Customize style using Maputnik editor
- Open the respective style json in this repo, like [local1-versatiles/colorful_style.json](local1-versatiles/colorful_style.json) : click "Raw" button to get the raw content in browser, and copy the browser URL 
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

## map1.html 

It's a very basic, no-frills map using the Maplibre JS library.

References the CDNs only.

DISCLAIMER: This map has zero intervention for Indianization done on it; hence all disputed borders are shown. Do not use in production. It's there as minimum working code to use as template to build from.


## map2.html

**Self-hosting:**
- All the dependencies : style json, sprites json & png, glyphs : Are localized and stored in "local1-versatiles" folder, about 80MB in total, majority of it being the glyphs.
- The JS, CSS are copied from the CDNs as of v5.7.3 (copied on 2025-09-22).
- Glyphs sourced from https://github.com/versatiles-org/versatiles-fonts/releases : downloaded the fonts.tar.gz, and copied over folders of noto_sans_regular and noto_sans_bold.
- Style json: colorful_style.json is copied from https://tiles.versatiles.org/assets/styles/colorful/style.json (copied on 2025-09-22) and then some changes have been made to it.
- When running in local, if a resource url starts with this repo's deployment url, then it is replaced by the local url so that you can run the map in local with the local sprites and glyphs loaded. This is done using `transformRequest` option in map declaration and is adapted from (but later heavily changed) https://github.com/mapbox/mapbox-gl-js/pull/9225#issuecomment-578089885
- Sprites .png and .json sourced from path https://tiles.versatiles.org/assets/sprites/basics/sprites given in the style json (copied on 2025-09-22).

**Note:** In case you're deploying this map on your own site, pls change the value of `BASEURL` in map2.html to your hosted location accordingly.

**Indianizing the map:**
- Incorporated changes documented on https://github.com/osm-in/osm-in.github.io/issues/87#issuecomment-3180638831 to hide disputed boundaries, add Indian state boundaries.


**Other features:**
- Added navigation control including a compass button that shows the direction and tilt of the map (right-click + drag to tilt/rotate) , and resets on clicking.
- Added fullscreen control button.
- Made the map render on a globe (zoom out to see it) using setProjection function. Source: https://maplibre.org/maplibre-gl-js/docs/examples/display-a-globe-with-a-vector-map/ .

**Jump links to what we can edit here:**
- the vector style json that controls how things are rendered: [local1-versatiles/colorful_style.json](local1-versatiles/colorful_style.json) 
- Sprites (Icons) for POIs: [local1-versatiles/assets/sprites/basics](local1-versatiles/assets/sprites/basics)
- The map HTML and JS: [map2.html](map2.html)

**Other info**
- Vector tile source URL being used: `https://vector.openstreetmap.org/shortbread_v1/{z}/{x}/{y}.mvt` . It was `https://tiles.versatiles.org/tiles/osm/{z}/{x}/{y}` earlier.
- This is specified in the style json used by the map, not in the main JS directly,

