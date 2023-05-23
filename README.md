# TravelTracker

A travel app for tracking and organizing your journey data.

## FEATURE

- work on android
- select and show gpx track
- auto search image to attach on gpx track
- map marker cluster
- gallery show all images in external storage

## TODO

### new feature

- [ ] TravelTrack class as a basic data structure
- [ ] TrackAsset class as a asset linked with TravelTrack, with extra data like location, time, tag, etc.
- [ ] Create TravelTrack
  - [ ] Auto search image to attach on gpx track
- [ ] Create/Attach TrackAsset
  - [ ] Determine if asset is already linked in current TravelTrack
- [ ] Filter assets by time, location, tag, type, marker cluster, etc.
- [ ] pages
  - [ ] map view
    - [x] Group Asset in map page
    - [ ] Better movement of map page
      - [ ] Focus on track / asset
      - [ ] Follow track by slider
      - [ ] Follow user location
      - [ ] Highlight track / asset
      - [ ] *Jump to temporary marker*
    - [ ] Show partial track 
      - [ ] control by slider
      - [ ] Trksegs that isn't intersect
  - [ ] gallery view
  - [ ] celender view
  - [ ] *timeline view*
  - [ ] Travel Stat page
- [ ] Manipulate multiple TravelTrack simultaneously
  - [ ] Show total distance, time, etc.

#### modify track

#### record track

### bug fix / refactor / improvement

- [ ] map page
  - [x] rename track page to map page
  - [ ] Slow down double tap and drag zoom speed