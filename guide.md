# Inspection guide

- [The Basics](#the-basics)
- [Dynamic query with **find**](#dynamic-query-with-find)
- [Inspectable attributes](#inspectable-attributes)
- [Views using **@Binding**](#views-using-binding)
- [Views using **@ObservedObject**](#views-using-observedobject)
- [Views using **@State**, **@Environment** or **@EnvironmentObject**](#views-using-state-environment-or-environmentobject)
- [Custom **ViewModifier**](#custom-viewmodifier)
- [Inspecting a mix of UIKit and SwiftUI](#inspecting-a-mix-of-uikit-and-swiftui)
- [Advanced topics](#advanced-topics)

## The Basics

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

final class ContentViewTests: XCTestCase {

    func testStringValue() throws { // 2.
        let sut = ContentView()
        let value = try sut.inspect().text().string() // 3.
        XCTAssertEqual(value, "Hello, world!")
    }
}
```
So, you need to do the following:

1. Add `import ViewInspector`
2. Annotate the test function with `throws` keyword to not mess with the bulky `do { } catch { }`. Test fails automatically upon exception.
3. Start the inspection with `.inspect()` function

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

Alternatively, you can use the subscript syntax: `hStack[1].anyView()`. All the multiple-descendants views, such as `hStack`, provide the standard set of functions available for a `RandomAccessCollection`, including `count`, `map`, `first(where: )`, etc.

## Dynamic query with `find`

Alternatively to writing the full path to the target view you can use one of the `find` functions so the library could locate the view for you.

`find` is fully compatible with the inspection call chain and can be triggered at any step:

```swift
try sut.inspect().anyView().find(ViewType.HStack.self).text(1)

try sut.inspect().find(where: { ... }).zStack()
```

You can query for a specific view with `find` or use `findAll` to get an array of all matching views.

The `find` traverses the hierarchy in the breadth-first order until it finds the first matching view. If none are found it throws an exception.

The `findAll` traverses the entire hierarchy in depth-first order and returns an array of all matching views. It does not throw and returns an empty array if none are found.

Here are a few examples of the `find` functions made available:

```swift
.find(text: "xyz") // returns Text
.find(button: "xyz") // returns Button which label contains Text("xyz")
.find(viewWithId: 7) // returns a view with modifier .id(7)
.find(viewWithTag: "Home") // returns a view with modifier .tag("Home")
.find(ViewType.HStack.self) // returns the first found HStack
.find(CustomView.self) // returns CustomView
.find(viewWithAccessibilityLabel: "Play button") // returns the first view with accessibilityLabel "Play button"
.find(viewWithAccessibilityIdentifier: "play_button") // returns the first view with accessibilityIdentifier "play_button"
```

#### `where` condition

Some of the functions also accept an additional parameter `where` for specifying a condition:

```swift
.find(ViewType.Text.self, where: { try $0.string() == "abc" })
```

The above is identical to `.find(text: "abc")`

#### `pathToRoot`

If you want to assure the library found the correct view you can read the `pathToRoot` value from any view to see the full inspection path:

```swift
let view = try sut.inspect().find(viewWithId: 42)
// print(view.pathToRoot) in the code or
// lldb: po view.pathToRoot
```

#### `parent`

There could be a use case when you want to find a specific view which only difference lays in its child views.

For example, locating a TableViewCell by its title.

In such a scenario you can find the child first, and then shift the focus to its parent.

Each view has a property `parent`, returning an anonymous view that you can unwrap and inspect:

```swift
let view = AnyView(HStack { Text("abc") })
let text = try sut.inspect().find(text: "abc")
let hStack = try text.parent().hStack()
let anyView = try text.parent().parent().anyView()
```

Alternatively, you can use `find` with parameter `relation: .parent` for locating a specific parent view:

```swift
let anyView = try text.find(ViewType.AnyView.self, relation: .parent)
```

The default value for the `relation` parameter is `.child`, but `.parent` inverts the direction of the search outwards.

So here is how you could find a TableViewCell by title:

```swift
let title = try sut.inspect().find(text: "Cell's title")
let cell = try title.find(TableViewCell.self, relation: .parent)
```

... or simply use this other variation of the `find` function:

```swift
let cell = try sut.find(TableViewCell.self, containing: "Cell's title")
```

This function accepts either a custom view type or types like `ViewType.HStack`, searches for a specific `Text` first and then locates the parent view of a given type.

#### Generic `find` function

All the `find` functions are based on one most generic version, that takes the `relation`, `traversal`, `skipFound` and `where` parameters:

```swift
let text = try sut.inspect()
    .find(relation: .child, traversal: .breadthFirst, skipFound: 2, where: {
        try $0.text().string() == "abc"
    })
    .text()
```

The parameter `traversal` allows you to toggle between "breadth-first" and "depth-first" traversal algorithms (defaults to `breadthFirst`).

The parameter `skipFound` is the number of matches you want to skip before returning the matching view you need (defaults to 0).

The condition is called with an anonymous view, giving you the flexibility of either unwrapping it for verifying it's type or just assuring a certain modifier is applied.

Here is how `find(viewWithId:)` is implemented in the library:

```swift
func find(viewWithId id: AnyHashable) throws -> InspectableView<ViewType.ClassifiedView> {
    return try find(where: { try $0.id() == id })
}
```

It does not care about the type of the view, but assures the `id` modifier exists and the values match.

#### Your custom `find` functions

Lastly, you can define your own `find` function for convenience by extending the `InspectableView` type:

```swift
extension InspectableView {
    
    func find(textWithFont font: Font) throws -> InspectableView<ViewType.Text> {
        return try find(ViewType.Text.self, where: {
            try $0.attributes().font() == font
        })
    }
}

let text = try sut.find(textWithFont: .headline)
```

## Inspectable attributes

**ViewInspector** provides access to various parameters held inside Views.

For a particular view type, there might be available values of `alignment` or `spacing`. For another, there could be `labelView` – a non-standard child view.

[ViewInspector's API coverage](readiness.md) is the place where you can see all the attributes available for each view type.

Let's consider `NavigationLink` as an example: it offers `contained view`, `label view`, `isActive: Bool`, `activate()` and `deactivate()`.

While the last three are self-explanatory, you can see it contains two views: one for the destination, another for the label.

The destination view is the "default" child, which gets returned as you continue chaining the view inspection calls (such as `hStack()` or `view(MyCustomView.self)`) after the `navigationLink()`. Such a direct descendant view is referred to as "contained view".

Label view, on the other hand, is an additional child view available for inspection on `NavigationLink`. In order to direct ViewInspector to that view, use `labelView()` call after the `navigationLink()`.

Let's say we have a view with a `NavigationLink` inside a `VStack`. The view body looks likes this:

```swift
var body: some View {
    NavigationView {
        VStack {
            // ...Various subviews...
            NavigationLink(destination: MyView(parameter: "Screen 1") {
                Text("Continue")
            }
        }
    }
}
```

Test code can find this `NavigationLink` either by traversing the tree or by searching for a navigation link with the given label:

```swift
let link = try sut.inspect().find(navigationLink: "Continue")
```

We can unwrap its contained view to test the parameter:

```swift
let nextView = try link.view(MyView.self).actualView()
XCTAssertEqual(nextView.parameter, "Screen 1")
```

or unwrap the label view and read its contents:

```swift
let label = try link.labelView().text()
XCTAssertEqual(try label.string(), "Continue")
```

## Views using `@Binding`

**ViewInspector** provides a helper initializer for the `Binding` that you can use to test such views without the need to define a `@State` variable:

```swift
func testBindingValueChanges() throws {
    let flag = Binding<Bool>(wrappedValue: false)
    let sut = ContentView(binding: flag)
    
    XCTAssertFalse(flag.wrappedValue)
    try sut.inspect().button().tap()
    XCTAssertTrue(flag.wrappedValue)
}
```

## Views using `@ObservedObject`

**ViewInspector** provides full support for such views, so you can inspect them without any intervention in the source code.

Unlike the views using `@State`, `@Environment` or `@EnvironmentObject`, the state changes inside `@Binding` and `@ObservedObject` can be evaluated with synchronous tests. You may consider, however, using the asynchronous approach described below, just for the sake of the tests consistency.

## Views using `@State`, `@Environment` or `@EnvironmentObject`

Inspection of these views requires a tiny refactoring of the view's source code, and you can choose between two approaches: the first one is more lightweight, the second one is more flexible.

### Approach #1

Consider you have a view with a `@State` variable:

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
    internal var didAppear: ((Self) -> Void)? // 1.
    
    var body: some View {
        Button(action: {
            self.flag.toggle()
        }, label: { Text(flag ? "True" : "False") })
        .onAppear { self.didAppear?(self) } // 2.
    }
}
```

The inspection will be fully functional inside the `didAppear` callback. You can configure the `didAppear` manually, or use a convenience function `on(_ keyPath:)`:

```swift
func testStateValueChanges() {
    var sut = ContentView()
    let exp = sut.on(\.didAppear) { view in
        XCTAssertFalse(try view.actualView().flag)
        try view.button().tap()
        XCTAssertTrue(try view.actualView().flag)
    }
    ViewHosting.host(view: sut)
    wait(for: [exp], timeout: 0.1)
}
```

An advantage of this variant is simplicity and a minimal intrusion in the source code. The downside is lack of flexibility: it is impossible to inspect the view in an arbitrary moment after `onAppear`.

### Approach #2

This one works for a more complex test scenarios where we want to inspect the view after a time span or when it receives an update from a publisher.

Here is a code snippet that you need to include in the **build** target to make it work:

```swift
import Combine
import SwiftUI

internal final class Inspection<V> {

    let notice = PassthroughSubject<UInt, Never>()
    var callbacks = [UInt: (V) -> Void]()

    func visit(_ view: V, _ line: UInt) {
        if let callback = callbacks.removeValue(forKey: line) {
            callback(view)
        }
    }
}
```

This code is intentionally not included in the **ViewInspector** so that your build target could remain independent from the framework, and since it requires `internal` access level it doesn't leave a trace.

After you add that `class Inspection<V>` to the build target, you should extend it in the **test target** with conformance to `InspectionEmissary` protocol:

```swift
extension Inspection: InspectionEmissary { }
```

Once you add these two snippets, the **ViewInspector** will be fully armed for inspecting any custom views with all types of the state.

---

For the same sample view we considered in the approach #1, instead of `onAppear / didAppear` dance we should use another two lines:

```swift
struct ContentView: View {

    @State var flag: Bool = false
    internal let inspection = Inspection<Self>() // 1.
    
    var body: some View {
        Button(action: {
            self.flag.toggle()
        }, label: { Text(flag ? "True" : "False") })
        .onReceive(inspection.notice) { self.inspection.visit(self, $0) } // 2.
    }
}
```

This allows us not only to repeat the original test case functionality:

```swift
final class ContentViewTests: XCTestCase {

    func testButtonTogglesFlag() {
        let sut = ContentView()
        let exp = sut.inspection.inspect { view in
            XCTAssertFalse(try view.actualView().flag)
            try view.button().tap()
            XCTAssertTrue(try view.actualView().flag)
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 0.1)
    }
}
```

... but also to gain the ability to delay the inspection:

```swift
let exp = sut.inspection.inspect(after: 0.5) { view in
    ...
}
```

... inspect right after a `Publisher` emits a value:

```swift
let exp = sut.inspection.inspect(onReceive: publisher) { view in
    ...
}
```

... and run multiple inspections within a single test:

```swift
final class ContentViewTests: XCTestCase {

    func testPublisherChangingValue() {
        let publisher = PassthroughSubject<Bool, Never>()
        let sut = ContentView(publisher: publisher)
        
        let exp1 = sut.inspection.inspect { view in
            XCTAssertFalse(try view.actualView().flag)
            publisher.send(true)
        }
        
        let exp2 = sut.inspection.inspect(onReceive: publisher) { view in
            XCTAssertTrue(try view.actualView().flag)
            publisher.send(false)
        }
        
        let exp3 = sut.inspection.inspect(after: 0.2) { view in
            XCTAssertFalse(try view.actualView().flag)
        }
        
        ViewHosting.host(view: sut)
        wait(for: [exp1, exp2, exp3], timeout: 0.3)
    }
}
```

Note that the inspection callbacks are **one-time-use**. So if you need to inspect the view for multiple values emitted by a publisher, you can configure the test the following way:

```swift
let exp1 = sut.inspection.inspect(onReceive: publisher) { view in
    // First value received
}
let exp2 = sut.inspection.inspect(onReceive: publisher.dropFirst()) { view in
    // Second value received
}
```

For the case of `@Environment` or `@EnvironmentObject`, you can perform the injection before hosting the view:

```swift
ViewHosting.host(view: sut.environmentObject(...))
```

## Custom **ViewModifier**

You can inspect custom `ViewModifier` independently, or together with the parent view hierarchy, to which the `ViewModifier` is applied using `.modifier(...)`. Consider an example:

```swift
struct MyViewModifier: ViewModifier {
    
    func body(content: Self.Content) -> some View {
        content
            .padding(.top, 15)
    }
}
```

The following test shows how you can extract the `modifier` and its `content` placeholder view using `modifier(_ type: T.Type)` and `viewModifierContent()` inspection calls respectively:

```swift
func testCustomViewModifierAppliedToHierarchy() throws {
    let sut = EmptyView().modifier(MyViewModifier())
    let modifier = try sut.inspect().emptyView().modifier(MyViewModifier.self)
    let content = try modifier.viewModifierContent()
    XCTAssertTrue(try content.hasPadding(.top))
    XCTAssertEqual(try content.padding(.top), 15)
}
```

If your `ViewModifier` uses references to SwiftUI state or environment, you may need to appeal to asynchronous inspection, similar to the custom view inspection techniques.

Approach #1:

```swift
struct MyViewModifier: ViewModifier {
    
    var didAppear: ((Self) -> Void)? // 1.
    
    func body(content: Self.Content) -> some View {
        content
            .padding(.top, 15)
            .onAppear { self.didAppear?(self) } // 2.
    }
}
```

Here is how you'd verify that `MyViewModifier` applies the padding:

```swift
func testViewModifier() {
    var sut = MyViewModifier()
    let exp = sut.on(\.didAppear) { modifier in
        XCTAssertEqual(try modifier.viewModifierContent().padding(.top), 15)
    }
    let view = EmptyView().modifier(sut)
    ViewHosting.host(view: view)
    wait(for: [exp], timeout: 0.1)
}
```

Approach #2:

```swift
struct MyViewModifier: ViewModifier {
    
    let inspection = Inspection<Self>() // 1.
        
    func body(content: Self.Content) -> some View {
        content
            .padding(.top, 15)
            .onReceive(inspection.notice) { self.inspection.visit(self, $0) } // 2.
    }
}
```

And the test:

```swift
func testViewModifier() {
    let sut = MyViewModifier()
    let exp = sut.inspection.inspect(after: 0.1) { modifier in
        XCTAssertEqual(try modifier.viewModifierContent().padding(.top), 15)
    }
    let view = EmptyView().modifier(sut)
    ViewHosting.host(view: view)
    wait(for: [exp], timeout: 0.2)
}
```

If your custom `ViewModifier` references an `@EnvironmentObject` or requires setting an `EnvironmentKey`, you can do that right before hosting a view with the modifier:

```swift
let view = EmptyView().modifier(sut).environmentObject(envObject)
ViewHosting.host(view: view)
```

## Inspecting a mix of UIKit and SwiftUI

If your custom view is `UIViewRepresentable` or `UIViewControllerRepresentable`, there is a possibility of accessing its genuine UIKit instance on screen:

```swift
let swiftuiView = try sut.inspect().find(MyCustomView.self)
let uikitView = try swiftuiView.actualView().uiView() // or .viewController()
```

Note that UIKit hierarchy gets added on screen asynchronously - so you need to use one of the async inspection approaches discussed above. See some [examples in the tests](https://github.com/nalexn/ViewInspector/blob/master/Tests/ViewInspectorTests/ViewHostingTests.swift#L105C31-L105C31).

From there you can use UIKit API to inspect subviews. However, if you're using UIKit just as a middleware and child content is again SwiftUI view, an easier way might be using the `CustomInspectable` protocol added as part of [this proposal](https://github.com/nalexn/ViewInspector/pull/288).

## Advanced topics

- [Styles](guide_styles.md)
- [Gestures](guide_gestures.md)
- [View Hosting on watchOS](guide_watchOS.md)
- [Alert, Sheet, ActionSheet, FullScreenCover and Popover](guide_popups.md)