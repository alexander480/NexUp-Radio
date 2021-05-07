# UserAccountVC

``` swift
class UserAccountVC: UIViewController, UITableViewDelegate, UITableViewDataSource 
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

### `options`

``` swift
let options = ["Favorites", "Dislikes", "Recently Played", "Premium"]
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

### `viewDidAppear(_:)`

``` swift
override func viewDidAppear(_ animated: Bool) 
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
