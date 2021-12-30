# View Hosting on watchOS

Because of WatchKit API limitations **ViewInspector** currently cannot automatically host your views for asynchronous tests - you need to add [this swift file](https://github.com/nalexn/ViewInspector/blob/master/.watchOS/watchOS-Ext/watchOSApp%2BTestable.swift) to your **watchOS extension target**.

Then, add the appropriate code snippet, depending on your setup:

### If your watchOS project is using `@main`

1. Make sure to add `WKExtensionDelegate` and reference it in the `App` using `@WKExtensionDelegateAdaptor`.
2. Add `let testViewSubject = TestViewSubject([])` as an instance variable to the `ExtensionDelegate`.
3. Add `.testable(extDelegate.testViewSubject)` to your `ContentView` inside `WindowGroup`.

The final code should look similar to this:

```swift
final class ExtensionDelegate: NSObject, WKExtensionDelegate {
    let testViewSubject = TestViewSubject([]) // #2
}

@main
struct MyWatchOSApp: App {
    
    @WKExtensionDelegateAdaptor(ExtensionDelegate.self) var extDelegate // #1
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .testable(extDelegate.testViewSubject) // #3
        }
    }
}
```

### If your watchOS project is using `storyboard`

1. Make sure your root interface controller is a `WKHostingController` descendant.
2. Add `let testViewSubject = TestViewSubject([])` as an instance variable to your root interface controller.
3. Add `.testable(testViewSubject)` to your `ContentView`
4. Replace `var body: ContentView` with `var body: RootView<ContentView>`
5. Replace `WKHostingController<ContentView>` with `WKHostingController<RootView<ContentView>>`

The final code should look similar to this:

```swift
final class RootInterfaceController: WKHostingController<RootView<ContentView>> { // #1 , #5
    
    let testViewSubject = TestViewSubject([]) // #2
    
    override var body: RootView<ContentView> { // #4
        return ContentView()
            .testable(testViewSubject) // #3
    }
}

struct ContentView: View {
    var body: some View {
        Text("Hi")
    }
}
```

## Consequences of intruding the main build target's code

The proposed code snippets are using `conditional compilation` to minimize the footprint in the main build target.

The condition `#if !(os(watchOS) && DEBUG)` fully disintegrates the test code in `Release` builds and replaces it with these primitives:

```swift
typealias RootView<T> = T
typealias TestViewSubject = Set<Int>

extension View {
    @inline(__always)
    func testable(_ injector: TestViewSubject) -> Self {
        self
    }
}
```
