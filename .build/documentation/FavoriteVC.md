# FavoriteVC

``` swift
class FavoriteVC: UIViewController, UITableViewDelegate, UITableViewDataSource 
```

## Inheritance

`UITableViewDataSource`, `UITableViewDelegate`, `UIViewController`

## Properties

### `bannerID`

``` swift
let bannerID = "ca-app-pub-6543648439575950/8381413905"
```

### `fullScreenID`

``` swift
let fullScreenID = "ca-app-pub-6543648439575950/9063940183"
```

### `songs`

``` swift
var songs 
```

### `tableTimer`

``` swift
var tableTimer 
```

### `timer`

``` swift
var timer 
```

### `tableView`

``` swift
@IBOutlet weak var tableView: UITableView!
```

### `backgroundImage`

``` swift
@IBOutlet weak var backgroundImage: UIImageView!
```

### `circleButton`

``` swift
@IBOutlet weak var circleButton: ButtonClass!
```

### `progressBar`

``` swift
@IBOutlet weak var progressBar: UIProgressView!
```

## Methods

### `viewDidLoad()`

``` swift
override func viewDidLoad() 
```

### `tableView(_:heightForRowAt:)`

``` swift
func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat 
```

### `tableView(_:numberOfRowsInSection:)`

``` swift
func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int 
```

### `tableView(_:cellForRowAt:)`

``` swift
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell 
```
