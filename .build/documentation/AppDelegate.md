# AppDelegate

``` swift
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate 
```

## Inheritance

`UIApplicationDelegate`, `UIResponder`

## Properties

### `window`

``` swift
var window: UIWindow?
```

### `persistentContainer`

``` swift
lazy var persistentContainer: NSPersistentContainer 
```

## Methods

### `application(_:didFinishLaunchingWithOptions:)`

``` swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool 
```

### `applicationWillResignActive(_:)`

``` swift
func applicationWillResignActive(_ application: UIApplication) 
```

### `applicationDidEnterBackground(_:)`

``` swift
func applicationDidEnterBackground(_ application: UIApplication) 
```

### `applicationWillEnterForeground(_:)`

``` swift
func applicationWillEnterForeground(_ application: UIApplication) 
```

### `applicationDidBecomeActive(_:)`

``` swift
func applicationDidBecomeActive(_ application: UIApplication) 
```

### `applicationWillTerminate(_:)`

``` swift
func applicationWillTerminate(_ application: UIApplication) 
```

### `saveContext()`

``` swift
func saveContext() 
```
