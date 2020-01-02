# ViewInspector for SwiftUI

![Platform](https://img.shields.io/badge/platform-ios%20%7C%20tvos%20%7C%20watchos%20%7C%20macos-lightgrey) [![Build Status](https://travis-ci.com/nalexn/ViewInspector.svg?branch=master)](https://travis-ci.com/nalexn/ViewInspector) [![codecov](https://codecov.io/gh/nalexn/ViewInspector/branch/master/graph/badge.svg)](https://codecov.io/gh/nalexn/ViewInspector)

**ViewInspector** is a library for unit testing SwiftUI views.
It allows for traversing a view hierarchy at runtime providing direct access to the underlying `View` structs.

## Why?

SwiftUI views are a function of state. We can provide the input, but couldn't verify the output. Until now!

## Features

#### 1. Verify the view's inner state

You can dig into the hierarchy and read actual state values on any SwiftUI View:

```swift
let view = ContentView()
let value = try view.inspect().text().string()
XCTAssertEqual(value, "Hello, world!")
```

#### 2. Trigger side effects

You can simulate user interaction by programmatically triggering system-controls callbacks:

```swift
let button = try view.inspect().hStack().button(3)
try button.tap()

let view = try view.inspect().list().view(ItemView.self, 15)
try view.callOnAppear()
```

#### 3. Extract custom views from the hierarchy of any depth

It is possible to obtain a copy of your custom view with actual state and references from the hierarchy of any depth:

```swift
let sut = try view.inspect().tabView().navigationView()
    .overlay().anyView().view(CustomView.self).actualView()
XCTAssertTrue(sut.isUserLoggedIn)
```

## FAQs

### Which views and modifiers are supported?

Pretty much all! Check out the [detailed list](readiness.md).

The framework is still expanding, as there are hundreds of inspectable attributes in SwiftUI that are not included yet.

Contributions are welcomed! To get some inspiration, read the [story](https://nalexn.github.io/swiftui-unit-testing/?utm_source=nalexn_github) behind creating this framework.

### Is it using private APIs?

**ViewInspector** is using official Swift reflection API to dissect the view structures.

So this framework is production-friendly for the case if you accidentally (or intentionally) linked it with the build target.

### How do I add it to my Xcode project?

1. In Xcode select **File ⭢ Swift Packages ⭢ Add Package Dependency...**
2. Copy-paste repository URL: **https://github.com/nalexn/ViewInspector**
3. Hit **Next** two times, under **Add to Target** select your test target. There is no need to add it to the build target.
4. Hit **Finish**

### How do I use it in my project?

Cosidering you have a view:

```swift
struct ContentView: View {
    var body: some View {
        Text("Hello, world!")
    }
}
```
Your test file would look like this:

```swift
import XCTest
import ViewInspector // 1.
@testable import MyApp

extension ContentView: Inspectable { } // 2.

final class ContentViewTests: XCTestCase {

    func testStringValue() throws { // 3.
        let sut = ContentView()
        let value = try sut.inspect().text().string() // 4.
        XCTAssertEqual(value, "Hello, world!")
    }
}
```
So, you need to do the following:

1. Add `import ViewInspector`
2. Extend your view to conform to `Inspectable` in the test target scope.
3. Annotate the test function with `throws` keyword to not mess with the bulky `do { } catch { }`. Test fails automatically upon exception.
4. Start the inspection with `.inspect()` function

## Inspection guide

After the `.inspect()` call you need to repeat the structure of the `body` by chaining corresponding functions named after the SwiftUI views.

```swift
struct MyView: View {
    var body: some View {
        HStack {
           Text("Hi")
           AnyView(OtherView())
        }
    }
}

struct OtherView: View {
    var body: some View {
        Text("Ok")
    }
}
```

In this case you can obtain access to the `Text("Ok")` with the following chain:

```swift
let view = MyView()
view.inspect().hStack().anyView(1).view(OtherView.self).text()
```

Note that after `.hStack()` you're required to provide the index of the view you're retrieving: `.anyView(1)`. For obtaining `Text("Hi")` you'd call `.text(0)`.

You can save the intermediate result in a variable and reuse it for further inspection:

```swift
let view = MyView()
let hStack = try view.inspect().hStack()
let hiText = try hStack.text(0)
let okText = try hStack.anyView(1).view(OtherView.self).text()
```

### Custom views using `@EnvironmentObject`

Currently, **ViewInspector** does not support SwiftUI's native environment injection through `.environmentObject(_:)`, however you still can inspect such views by explicitely providing the environment object to every view that uses it. A small refactoring of the view's source code is required.

Consider you have a view that has a `@EnvironmentObject` variable:

```swift
struct MyView: View {

    @EnvironmentObject var state: AppState
    
    var body: some View {
        Text(state.showHi ? "Hi" : "Bye")
    }
}
```

You can inspect it with **ViewInspector** after refactoring the following way:

```swift
struct MyView: View {

    @EnvironmentObject var state: AppState
    
    var body: some View {
        body(state)
    }
    
    func body(_ state: AppState) -> some View {
        Text(state.showHi ? "Hi" : "Bye")
    }
}
```

In the `body(_:)`, make sure to reference the injected parameter instead of the variable from `self`. The error message *"Fatal error: No ObservableObject of type ... found. A View.environmentObject(_:) for ... may be missing as an ancestor of this view."* is the indicator that you still do. See [this issue](https://github.com/nalexn/ViewInspector/issues/4) for more info.

In the test target extend the view to conform to `InspectableWithOneParam` protocol:

```swift
import XCTest
import ViewInspector
@testable import MyApp

extension MyView: InspectableWithOneParam { }

```

After that you can extract the view in tests by explicitely providing the environment object:

```swift
let appState = AppState()
let view = MyView()
let value = try view.inspect(appState).text().string()
XCTAssertEqual(value, "Hi")
```

For the case when the view is embedded in the hierarchy:

```swift
let appState = AppState()
let view = HStack { AnyView(MyView()) }
try view.inspect().anyView(0).view(MyView.self, appState)
```

Note that you don't need to call `.environmentObject(_:)` in these cases.

Use `InspectableWithTwoParam` and `InspectableWithThreeParam` protocols for injecting two and three parameters as needed:

```swift
struct MyView: View {

    @EnvironmentObject var appState: AppState
    @Environment(\.workers) var workers: Workers
    
    var body: some View {
        body(appState, workers)
    }
    
    func body(_ appState: AppState, _ workers: Workers) -> some View {
        ...
    }
}

// Test Target:

extension MyView: InspectableWithTwoParam { }

let appState = AppState(), workers = Workers()
try view.inspect(appState, workers)
```

You are not bound to injecting only the `@EnvironmentObject`. Any typed parameters, including those injected with `@Environment`, would also work.

## Questions, concerns, suggestions?

Feel free to contact me on [Twitter](https://twitter.com/nallexn) or just submit an issue or a pull request on Github.

---

![license](https://img.shields.io/badge/license-mit-brightgreen) [![Twitter](https://img.shields.io/badge/twitter-nallexn-blue)](https://twitter.com/nallexn) [![blog](https://img.shields.io/badge/blog-medium-red)](https://medium.com/@nalexn)
