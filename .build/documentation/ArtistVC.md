# ArtistVC

``` swift
class ArtistVC: UIViewController, UITableViewDelegate, UITableViewDataSource 
```

## Inheritance

`UITableViewDataSource`, `UITableViewDelegate`, `UIViewController`

## Properties

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

### `artistClass`

``` swift
var artistClass 
```

### `artists`

``` swift
var artists 
```

### `timer`

``` swift
var timer 
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

### `tableView(_:didSelectRowAt:)`

``` swift
func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) 
```
