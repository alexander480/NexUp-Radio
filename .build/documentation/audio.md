# Audio

``` swift
class Audio: NSObject 
```

## Inheritance

`NSObject`

## Initializers

### `init(PlaylistName:)`

``` swift
init(PlaylistName: String) 
```

## Properties

### `player`

``` swift
var player 
```

### `playlist`

``` swift
var playlist 
```

### `songCount`

``` swift
var songCount = 0
```

### `currentPlaylist`

``` swift
var currentPlaylist = ""
```

### `limitReached`

``` swift
var limitReached = false
```

### `delegate`

``` swift
var delegate: AudioDelegate?
```

### `imageCache`

``` swift
let imageCache 
```

### `metadata`

``` swift
var metadata: [String: Any]?
```

### `previousSong`

``` swift
var previousSong: AVPlayerItem?
```

### `avWorker`

``` swift
let avWorker 
```

### `metadataWorker`

``` swift
let metadataWorker 
```

### `cc`

``` swift
let cc 
```

### `info`

``` swift
let info 
```

### `nc`

``` swift
let nc = NotificationCenter.default
```

### `session`

``` swift
let session 
```

## Methods

### `fetchMetadata()`

``` swift
func fetchMetadata() -> [String: Any]? 
```

### `playerDidFinishPlaying()`

``` swift
@objc func playerDidFinishPlaying() 
```

### `ccUpdate()`

``` swift
func ccUpdate() 
```

### `startPlaylist(Name:)`

``` swift
func startPlaylist(Name: String) 
```

### `startFavorites()`

``` swift
func startFavorites() 
```

### `togglePlayback()`

``` swift
func togglePlayback() 
```

### `skip(didFinish:)`

``` swift
func skip(didFinish: Bool) 
```
