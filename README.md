# ViewInspector

[![Build Status](https://travis-ci.com/nalexn/ViewInspector.svg?branch=master)](https://travis-ci.com/nalexn/ViewInspector) [![codecov](https://codecov.io/gh/nalexn/ViewInspector/branch/master/graph/badge.svg)](https://codecov.io/gh/nalexn/ViewInspector) ![Platform](https://img.shields.io/badge/platform-ios%20%7C%20tvos%20%7C%20watchos%20%7C%20macos-lightgrey)

ViewInspector is a library for traversing SwiftUI view hierarchy in runtime.

## Why?

SwiftUI views are a function of state. We can provide the input, but couldn't verify the output. Until now.

## Features

### Verify the view's state

```swift
let view = ContentView()
let value = try view.inspect().text().string()
XCTAssertEqual(value, "Hello, world!")
```

### Gain direct access to the views

```swift
let customView = try view.inspect().hStack().view(CustomView.self, 0)
XCTAssertTrue(customView.isToggleOn)
```

### Trigger side effects

```swift
let view = ContentView()
let button = try view.inspect().anyView().button()
try button.tap()
```

## Is it using private APIs?

ViewInspector is using official Swift reflection API to dissect the view structures. So this library is production-friendly, although it's strongly recommended to use it for debugging and unit testing purposes only.

## Is it production ready?

The library is already functional, but there are many views in SwiftUI that have not yet been fully anatomized.

**Contributions are welcomed!**

## How do I add it to my Xcode project?

1. In Xcode select **File ⭢ Swift Packages ⭢ Add Package Dependency...**
2. Copy-paste repository URL: **https://github.com/nalexn/ViewInspector**
3. Hit **Next** two times, under **Add to Target** select your test target
4. Hit **Finish**

## How do I use it in my project?

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

---

![license](https://img.shields.io/badge/license-mit-brightgreen) [![Twitter](https://img.shields.io/badge/twitter-nallexn-blue)](https://twitter.com/nallexn) [![blog](https://img.shields.io/badge/blog-medium-red)](https://medium.com/@nalexn)