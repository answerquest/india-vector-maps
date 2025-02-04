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
