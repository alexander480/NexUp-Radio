# Account

``` swift
class Account: NSObject 
```

## Inheritance

`NSObject`

## Initializers

### `init()`

``` swift
override init() 
```

## Properties

### `skipCount`

``` swift
var skipCount = 0
```

### `isPremium`

``` swift
var isPremium = false
```

### `favorites`

``` swift
var favorites 
```

### `dislikes`

``` swift
var dislikes 
```

### `recents`

``` swift
var recents 
```

## Methods

### `updateSkipCount(To:)`

``` swift
func updateSkipCount(To: Int) 
```

### `shouldRefreshSkipCount()`

``` swift
func shouldRefreshSkipCount() 
```

### `syncSkipCount()`

``` swift
func syncSkipCount() 
```

### `syncPremiumStatus()`

``` swift
func syncPremiumStatus() 
```

### `addSongToRecents()`

``` swift
func addSongToRecents() 
```

### `addSongToFavorites()`

``` swift
func addSongToFavorites() 
```

### `addSongToDislikes()`

``` swift
func addSongToDislikes() 
```

### `fetchRecentSongs()`

``` swift
func fetchRecentSongs() 
```

### `fetchFavoriteSongs()`

``` swift
func fetchFavoriteSongs() 
```

### `fetchDislikedSongs()`

``` swift
func fetchDislikedSongs() 
```

### `removeDislikedSongs()`

``` swift
func removeDislikedSongs() 
```

### `isFavoriteSong(Name:Completion:)`

``` swift
func isFavoriteSong(Name: String, Completion: @escaping (Bool) -> ()) 
```
