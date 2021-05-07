# NowPlayingVC

``` swift
class NowPlayingVC: UIViewController, GADInterstitialDelegate, AudioDelegate 
```

## Inheritance

[`AudioDelegate`](/AudioDelegate), `GADInterstitialDelegate`, `UIViewController`

## Properties

### `bannerID`

``` swift
let bannerID = "ca-app-pub-6543648439575950/8381413905"
```

### `fullScreenID`

``` swift
let fullScreenID = "ca-app-pub-6543648439575950/9063940183"
```

### `timer`

``` swift
var timer 
```

### `metadata`

``` swift
let metadata 
```

### `ads`

``` swift
let ads 
```

### `backgroundImage`

``` swift
@IBOutlet weak var backgroundImage: UIImageView!
```

### `controlCircleConstraint`

``` swift
@IBOutlet weak var controlCircleConstraint: NSLayoutConstraint!
```

### `controlCircleView`

``` swift
@IBOutlet weak var controlCircleView: UIView!
```

### `launchScreenCircleLogo`

``` swift
@IBOutlet weak var launchScreenCircleLogo: UIImageView!
```

### `launchScreenDeltaVel`

``` swift
@IBOutlet weak var launchScreenDeltaVel: UIImageView!
```

### `loadingView`

``` swift
@IBOutlet weak var loadingView: ViewClass!
```

### `loadingSpinner`

``` swift
@IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
```

### `loadingConstraint`

``` swift
@IBOutlet weak var loadingConstraint: NSLayoutConstraint!
```

### `sidebar`

``` swift
@IBOutlet weak var sidebar: UIView!
```

### `revealSidebarButton`

``` swift
@IBOutlet weak var revealSidebarButton: ButtonClass!
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

### `revealSidebarAction(_:)`

``` swift
@IBAction func revealSidebarAction(_ sender: Any) 
```

### `rightSwipe(_:)`

``` swift
@IBAction func rightSwipe(_ sender: Any) 
```

### `leftSwipe(_:)`

``` swift
@IBAction func leftSwipe(_ sender: Any) 
```

### `viewDidLoad()`

``` swift
override func viewDidLoad() 
```

### `didReachLimit()`

``` swift
func didReachLimit() 
```

### `toggleLoading(isLoading:)`

``` swift
func toggleLoading(isLoading: Bool) 
```

### `toggleSidebar()`

``` swift
func toggleSidebar() 
```

### `interstitialDidReceiveAd(_:)`

``` swift
func interstitialDidReceiveAd(_ ad: GADInterstitial) 
```
