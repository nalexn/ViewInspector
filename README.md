# ViewInspector for SwiftUI

![Platform](https://img.shields.io/badge/platform-ios%20%7C%20tvos%20%7C%20watchos%20%7C%20macos-lightgrey) [![Build Status](https://travis-ci.com/nalexn/ViewInspector.svg?branch=master)](https://travis-ci.com/nalexn/ViewInspector) [![codecov](https://codecov.io/gh/nalexn/ViewInspector/branch/master/graph/badge.svg)](https://codecov.io/gh/nalexn/ViewInspector) [![venmo](https://img.shields.io/badge/%F0%9F%8D%BA-Venmo-brightgreen)](https://venmo.com/nallexn)

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

### Custom views using `@ObservedObject`

**ViewInspector** provides full support of such views, so you can inspect them without any intervention to the source code.

Unlike the views using `@State`, `@Environment` or `@EnvironmentObject`, the state changes inside `@ObservedObject` can be evaluated with synchronous tests. You may consider, however, using the asynchronous approach described below, just for the sake of the tests consistency.

### Custom views using `@State`, `@Environment` or `@EnvironmentObject`

Inspection of these views requires a small refactoring of the view's source code. Consider you have a view with a `@State` variable:

```swift
struct ContentView: View {

    @State var flag: Bool = false
    
    var body: some View {
        Button(action: {
            self.flag.toggle()
        }, label: { Text(flag ? "True" : "False") })
    }
}
```

You can inspect it after adding these two lines:

```swift
struct ContentView: View {

    @State var flag: Bool = false
    var didAppear: ((Self) -> Void)? // 1.
    
    var body: some View {
        Button(action: {
            self.flag.toggle()
        }, label: { Text(flag ? "True" : "False") })
        .onAppear { self.didAppear?(self) } // 2.
    }
}
```

The inspection will be fully functional inside the `didAppear` callback (which is called asynchronously):

```swift
final class ContentViewTests: XCTestCase {

    func testButtonTogglesFlag() {
        var sut = ContentView()
        let exp = sut.on(\.didAppear) { view in
            XCTAssertFalse(view.flag)
            try view.inspect().button().tap()
            XCTAssertTrue(view.flag)
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 0.1)
    }
}
```

For the case of `@Environment` or `@EnvironmentObject`, perform the injection before hosting the view:

```swift
ViewHosting.host(view: sut.environmentObject(...))
```

You can introduce multiple points for inspection. For example, inside the `.onReceive(publisher) { ... }`:

```swift
struct ContentView: View {

    @State var flag: Bool = false
    let publisher: CurrentValueSubject<Bool, Never>
    
    var didAppear: ((Self) -> Void)?
    var didReceiveValue: ((Self) -> Void)?
    
    var body: some View {
        Text(flag ? "True" : "False")
        .onReceive(publisher) { value in
            self.flag = value
            self.didReceiveValue(self)
        }
        .onAppear { self.didAppear?(self) }
    }
}
```

The test may look like this:

```swift
final class ContentViewTests: XCTestCase {

    func testPublisherChangesText() {
        let publisher = CurrentValueSubject<Bool, Never>(false)
        var sut = ContentView(publisher: publisher)
        let exp1 = sut.on(\.didAppear) { view in
            let text = try sut.inspect().text().string()
            XCTAssertEqual(text, "False")
        }
        let exp2 = sut.on(\.didReceiveValue) { view in
            let text = try sut.inspect().text().string()
            XCTAssertEqual(text, "True")
        }
        ViewHosting.host(view: sut)
        publisher.send(true)
        wait(for: [exp1, exp2], timeout: 0.1)
    }
}
```

The `.on(_ keyPath:)` function is a convenience method for `XCTest` framework. You are free to use your favorite third-party testing framework and configure the callback directly, just make sure to unmount the view in the end by calling `ViewHosting.expel()`

```swift
var sut = ContentView()
sut.didAppear = { view in
    // inspect the view here
    ViewHosting.expel()
}
ViewHosting.host(view: sut)
```

## Questions, concerns, suggestions?

Feel free to contact me on [Twitter](https://twitter.com/nallexn) or just submit an issue or a pull request on Github.

---

[![blog](https://img.shields.io/badge/blog-github-blue)](https://nalexn.github.io/?utm_source=nalexn_github) [![venmo](https://img.shields.io/badge/%F0%9F%8D%BA-Venmo-brightgreen)](https://venmo.com/nallexn)