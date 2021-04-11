# Inspection guide


- [The Basics](#the-basics)
- [Dynamic query with **find**](#dynamic-query-with-find)
- [Views using **@Binding**](#views-using-binding)
- [Views using **@ObservedObject**](#views-using-observedobject)
- [Views using **@State**, **@Environment** or **@EnvironmentObject**](#views-using-state-environment-or-environmentobject)
- [Custom **ViewModifier**](#custom-viewmodifier)
- [Custom **ButtonStyle** or **PrimitiveButtonStyle**](#custom-buttonstyle-or-primitivebuttonstyle)
- [Custom **LabelStyle**](#custom-labelstyle)
- [Custom **GroupBoxStyle**](#custom-groupboxstyle)
- [Custom **ToggleStyle**](#custom-togglestyle)
- [Custom **ProgressViewStyle**](#custom-progressviewstyle)
- [Custom Styles](#custom-styles)
- [Gestures](#gestures)

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
.find(CustomView.self) // returns CustomView
.find(ViewType.HStack.self) // returns the first found HStack
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

This function accepts either `Inspectable` custom view or types like `ViewType.HStack`, searches for a specific `Text` first and then locates the parent view of a given type.

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

#### Limitations

There are a few scenarious when `find` function is unable to automatically traverse the whole view.

One of such cases is a custom view that does not conform to `Inspectable`. Adding a corresponding extension in the test scope solves this problem.

In addition to that, there are a few SwiftUI modifiers which currently block the search:

* `navigationBarItems`
* `popover`
* `overlayPreferenceValue`
* `backgroundPreferenceValue`

While the first two can be unwrapped manually, the last two are notorious for blocking the inspection completely. The workaround is under investigation.

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

internal final class Inspection<V> where V: View {

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
extension Inspection: InspectionEmissary where V: Inspectable { }
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

Just like with the custom views, in order to inspect a custom `ViewModifier` extend it to conform to `Inspectable` protocol in the tests scope.

```swift
extension MyViewModifier: Inspectable { }
```

The following test shows how you can extract the `modifier` and its `content` view using `modifier(_ type: T.Type)` and `viewModifierContent()` inspection calls respectively:

```swift
func testCustomViewModifierAppliedToHierarchy() throws {
    let sut = EmptyView().modifier(MyViewModifier())
    let modifier = try sut.inspect().emptyView().modifier(MyViewModifier.self)
    let content = try modifier.viewModifierContent()
    XCTAssertTrue(try content.hasPadding(.top))
    XCTAssertEqual(try content.padding(.top), 15)
}
```

If your `ViewModifier` uses references to SwiftUI state or environment, you may need to appeal to asynchronous inspection, similar to custom view inspection techniques. You can take a slightly modified approach #1 described above:

```swift
struct MyViewModifier: ViewModifier {
    
    var didAppear: ((Self.Body) -> Void)? // 1.
    
    func body(content: Self.Content) -> some View {
        content
            .padding(.top, 15)
            .onAppear { self.didAppear?(self.body(content: content)) } // 2.
    }
}
```

Here is how you'd verify that `MyViewModifier` applies the padding:

```swift
func testViewModifier() {
    var sut = MyViewModifier()
    let exp = XCTestExpectation(description: #function)
    sut.didAppear = { body in
        body.inspect { view in
            XCTAssertEqual(try view.padding(.top), 15)
        }
        ViewHosting.expel()
        exp.fulfill()
    }
    let view = EmptyView().modifier(sut)
    ViewHosting.host(view: view)
    wait(for: [exp], timeout: 0.1)
}
```

An example of an asynchronous `ViewModifier` inspection can be found in the sample project: [ViewModifier](https://github.com/nalexn/clean-architecture-swiftui/blob/master/CountriesSwiftUI/UI/RootViewModifier.swift) | [Tests](https://github.com/nalexn/clean-architecture-swiftui/blob/master/UnitTests/UI/RootViewAppearanceTests.swift)

## Custom `ButtonStyle` or `PrimitiveButtonStyle`

Verifying the button style in use is easy:

```swift
XCTAssertTrue(try sut.inspect().buttonStyle() is PlainButtonStyle)
```

Assuming you want to test how your custom `ButtonStyle` works for different `isPressed` status, consider the following example:

```swift
struct CustomButtonStyle: ButtonStyle {
    
    public func makeBody(configuration: CustomButtonStyle.Configuration) -> some View {
        configuration.label
            .blur(radius: configuration.isPressed ? 5 : 0)
    }
}
```

The library provides a custom inspection function `inspect(isPressed: Bool)` for testing the `ButtonStyle`:

```swift
func testCustomButtonStyle() throws {
    let sut = CustomButtonStyle()
    XCTAssertEqual(try sut.inspect(isPressed: false).blur().radius, 0)
    XCTAssertEqual(try sut.inspect(isPressed: true).blur().radius, 5)
}
```

Now an example for a custom `PrimitiveButtonStyle`:

```swift
struct CustomPrimitiveButtonStyle: PrimitiveButtonStyle {
    
    func makeBody(configuration: PrimitiveButtonStyle.Configuration) -> some View {
        CustomButton(configuration: configuration)
    }
    
    struct CustomButton: View {
        
        let configuration: PrimitiveButtonStyle.Configuration
        @State private(set) var isPressed = false

        var body: some View {
            configuration.label
                .blur(radius: isPressed ? 5 : 0)
                .onTapGesture {
                    self.isPressed = true
                    self.configuration.trigger()
                }
        }
    }
}
```

You can get access to the root view:

```swift
func testCustomPrimitiveButtonStyle() throws {
    let sut = CustomPrimitiveButtonStyle()
    let view = try sut.inspect().view(CustomPrimitiveButtonStyle.CustomButton.self)
    ...
}
```
However, since that root view is likely to be a custom view itself, it's better to inspect it directly. There is a helper initializer available for `PrimitiveButtonStyleConfiguration` where you provide `onTrigger` closure for verifying that your `PrimitiveButtonStyle` calls `trigger()` in the right time:

```swift
func testCustomPrimitiveButtonStyleButton() throws {
    let triggerExp = XCTestExpectation(description: "trigger()")
    triggerExp.expectedFulfillmentCount = 1
    triggerExp.assertForOverFulfill = true
    let config = PrimitiveButtonStyleConfiguration(onTrigger: {
        triggerExp.fulfill()
    })
    let view = CustomPrimitiveButtonStyle.CustomButton(configuration: config)
    let exp = view.inspection.inspect { view in
        let label = try view.styleConfigurationLabel()
        XCTAssertEqual(try label.blur().radius, 0)
        try label.callOnTapGesture()
        let updatedLabel = try view.styleConfigurationLabel()
        XCTAssertEqual(try updatedLabel.blur().radius, 5)
    }
    ViewHosting.host(view: view)
    wait(for: [exp, triggerExp], timeout: 0.1)
}
```

## Custom **LabelStyle**

For verifying the label style you can just do:

```swift
XCTAssertTrue(try sut.inspect().labelStyle() is IconOnlyLabelStyle)
```

Consider the following example:

```swift
struct CustomLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack {
            configuration.title
                .blur(radius: 3)
            configuration.icon
                .padding(5)
        }
    }
}
```

The test for this style may look like this:

```swift
func testCustomLabelStyle() throws {
    let sut = CustomLabelStyle()
    let title = try sut.inspect().vStack().styleConfigurationTitle(0)
    let icon = try sut.inspect().vStack().styleConfigurationIcon(1)
    XCTAssertEqual(try title.blur().radius, 3)
    XCTAssertEqual(try icon.padding(), EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
    XCTAssertEqual(try icon.padding(.all), 5)
}
```

## Custom **GroupBoxStyle**

Consider the following example:

```swift
struct CustomGroupBoxStyle: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack {
            configuration.label
                .brightness(3)
            configuration.content
                .blur(radius: 5)
        }
    }
}
```

The test for this style may look like this:

```swift
func testCustomGroupBoxStyleInspection() throws {
    let sut = CustomGroupBoxStyle()
    XCTAssertEqual(try sut.inspect().vStack().styleConfigurationLabel(0).brightness(), 3)
    XCTAssertEqual(try sut.inspect().vStack().styleConfigurationContent(1).blur().radius, 5)
}
```

## Custom **ToggleStyle**

Consider the following example:

```swift
struct CustomToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .blur(radius: configuration.isOn ? 5 : 0)
    }
}
```

The library provides a custom inspection function `inspect(isOn: Bool)` for testing the custom `ToggleStyle`:

```swift
func testCustomToggleStyle() throws {
    let sut = CustomToggleStyle()
    XCTAssertEqual(try sut.inspect(isOn: false).styleConfigurationLabel().blur().radius, 0)
    XCTAssertEqual(try sut.inspect(isOn: true).styleConfigurationLabel().blur().radius, 5)
}
```

## Custom **ProgressViewStyle**

Consider the following example:

```swift
struct CustomProgressViewStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack {
            configuration.label
                .brightness(3)
            configuration.currentValueLabel
                .blur(radius: 5)
            Text("Completed: \(Int(configuration.fractionCompleted.flatMap { $0 * 100 } ?? 0))%")
        }
    }
}
```

The library provides a custom inspection function `inspect(fractionCompleted: Double?)` for testing the custom `ProgressViewStyle`:

```swift
func testCustomProgressViewStyle() throws {
    let sut = CustomProgressViewStyle()
    XCTAssertEqual(try sut.inspect(fractionCompleted: nil).vStack().styleConfigurationLabel(0).brightness(), 3)
    XCTAssertEqual(try sut.inspect(fractionCompleted: nil).vStack().styleConfigurationCurrentValueLabel(1).blur().radius, 5)
    XCTAssertEqual(try sut.inspect(fractionCompleted: 0.42).vStack().text(2).string(), "Completed: 42%")
}
```
## **Custom Styles**

A custom style is a type that implements standard interaction behavior and/or a custom 
appearance for all views that apply the custom style in a view hiearchy.

A custom style starts with a protocol that concrete styles must conform to. Such a protocol
has the following requirements:
* An associated type called `Body` that conforms to `View`.
* A type alias called `Configuration` equal to the type used to pass configuration information
to `makeBody(configuration:)`.
* A method called `makeBody(configuration:)` that constructs a view of type `Body`.

The following example illustrates a protocol defining a style, a concrete style conforming to
the style, and a view that applies the style.

```swift
struct HelloWorldStyleConfiguration {}

protocol HelloWorldStyle {
    associatedtype Body: View

    typealias Configuration = HelloWorldStyleConfiguration
    
    func makeBody(configuration: Self.Configuration) -> Self.Body
}

struct DefaultHelloWorldStyle: HelloWorldStyle {
    func makeBody(configuration: HelloWorldStyleConfiguration) -> some View {
        ZStack {
            Rectangle()
                .strokeBorder(Color.accentColor, lineWidth: 1, antialiased: true)
        }
    }
}

struct HelloWorld: View {
    @Environment(\.helloWorldStyle) var style
    var body: some View {
        ZStack {
            Text("Hello World!")
            style.makeBody(configuration: HelloWorldStyle.Configuration())
        }
    }
}
```

Observe that  `HelloWorld` reads an environment value with the key `helloWorldStyle`
and applies this style by calling its `makeBody(configuration:)` method. In order to enable
this capability, it is necessary to define a custom enviroment value, as illustrated below:

```Swift
struct HelloWorldStyleKey: EnvironmentKey {
    static var defaultValue: AnyHelloWorldStyle = AnyHelloWorldStyle(DefaultHelloWorldStyle())
}

extension EnvironmentValues {
    var helloWorldStyle: AnyHelloWorldStyle {
        get { self[HelloWorldStyleKey.self] }
        set { self[HelloWorldStyleKey.self] = newValue }
    }
}
```

Swift doesn't allow the environment value with the type `HelloWorldStyle` because it has
an associated type. As of this writing, Swift does not support computed properties having
opaque types. Hence, the environment variable has to hold a type-erased `HelloWorldStyle`. 
The following type illustrates the simplest method for type-erasing `HellowWorldStyle`:

```Swift
struct AnyHelloWorldStyle: HelloWorldStyle {
    private var _makeBody: (HelloWorldStyle.Configuration) -> AnyView

    init<S: HelloWorldStyle>(_ style: S) {
        _makeBody = { configuration in
            AnyView(style.makeBody(configuration: configuration))
        }
    }

    func makeBody(configuration: HelloWorldStyle.Configuration) -> some View {
        _makeBody(configuration)
    }
}
```

To emulate SwiftUI's approach to styles, it is necessary to wrap setting the environment value.
This not only encapsulates the type-erasure of the style, but it retains the type of the style as
part of the view's hiearchy. The following view modifier illustrates how to accomplish this:

```Swift
struct HelloWorldStyleModifier<S: HelloWorldStyle>: ViewModifier {
    let style: S
    
    init(_ style: S) {
        self.style = style
    }
    
    func body(content: Self.Content) -> some View {
        content
            .environment(\.helloWorldStyle, AnyHelloWorldStyle(style))
    }
}

extension View {
    func helloWorldStyle<S: helloWorldStyle>(_ style: S) -> some View {
        modifier(HelloWorldStyleModifier(style))
    }
}
```

The following example illustrates how to define a concrete style and apply it to a view 
hiearchy:

```Swift
struct Content: View {
    var body: some View {
        HelloWorld()
            .helloWorldStyle(RedOutlineHelloWorldStyle())
    }
}

struct RedOutlineHelloWorldStyle: HelloWorldStyle {
    func makeBody(configuration: HelloWorldStyleConfiguration) -> some View {
        ZStack {
            Rectangle()
                .strokeBorder(Color.red, lineWidth: 3, antialiased: true)
        }
    }
}
```

**ViewInspector** provides support for custom styles.

A test can verify the style applied to a view hiearchy. For example:

```Swift
let sut = EmptyView().helloWorldStyle(RedOutlineHelloWorldStyle())
XCTAssertNoThrow(try sut.inspect().customStyle("helloWorldStyle") is RedOutlineHelloWorldStyle)
```

Note, the `customStyle(_:)` method accepts a string-value indicating the name of the 
convenience method used to apply the style. This method only works if the style definition
meets the following conditions:
* A type defines a view modifier that wraps setting the environment value used by the
custom style. The name of this type has the format `<style>Modifier`, where `style` is the
of the style protocol.
* An extension of `View` defines a convenience method that applies the modifier to a view.  

A test can inspect a style by defining a custom inspector. For example:

```Swift
extension RedOutlineHelloWorldStyle {
    func inspect() throws -> InspectableView<ViewType.ClassifiedView> {
        let configuration = HelloWorldStyleConfiguration()
        let view = try makeBody(configuration: configuration).inspect()
        return try view.classify()
    }
}
```

With this extension, test can inspect the concrete style `RedOutlineHelloWorldStyle`. For
example:

```Swift
    let style = RedOutlineHelloWorldStyle()
    XCTAssertNoThrow(try style.inspect().zStack()
```

A test may need to use asynchronous inspection of a concrete style; for example, if it
contains state. This requires refactoring the concrete style:

```Swift
struct RedOutlineHelloWorldStyle: HelloWorldStyle {
    func makeBody(configuration: HelloWorldStyleConfiguration) -> some View {
        StyleBody(configuration: configuration))
    }
    
    struct StyleBody: View {
        let configuration: HelloWorldStyleConfiguration
        
        internal var didAppear: ((Self) -> Void)?
        
        var body: some View {
            ZStack {
                Rectangle()
                    .strokeBorder(Color.red, lineWidth: 3, antialiased: true)
            }
            .onAppear { self.didAppear?(self) }
        }
    }
}
```

Inspection becomes fully functional in the scope of  `didAppear(_:)`. The test can manually
configure `didAppear(_:)` or use the `on(_:)` convenience method:

```Swift
extension RedOutlineHelloWorldStyle.StyleBody: InspectableView {}

final class HelloWorldStyleTest: XCTestCase {

    func testRedOutlineHelloWorldStyle() {
        let style = RedOutlineHelloWorldStyle(configuration: HelloWorldStyleConfiguration())
        var body = try style.inspect().view(RedOutlineHelloWorldStyle.StyleBody.self).actualView()
        let expectation = body.on(\.didAppear) { inspectedBody in
            let zStack = try inspectedBody.zStack()
            let rectangle = try zStack.shape(0)
            XCTAssertEqual(try rectangle.fillShapeStyle(Color.self), Color.red)
            XCTAssertEqual(try rectangle.strokeStyle().lineWidth, 1)
            XCTAssertEqual(try rectangle.fillStyle().isAntialiased, true)
        }
        ViewHosting.host(view: body)
        wait(for: [expectation], timeout: 1.0)
    }
}
```
## **Gestures**

SwiftUI defines a number of built-in gestures, including: `DragGesture`, `LongPressGesture`,
`MagnificationGesture`, `RotationGesture`, and `TapGesture`. An application can compose
these gestures using `ExclusiveGesture`, `SequenceGesture`, and `SimultaneousGesture`.

**ViewInspector** provides supports for both simple and composed gesture. Given the complex
nature of gestures, the following sections discuss different aspects of this support.

### **Gesture Modifiers**

A test can inspect a gesture attached to a view using the `gesture(_:including:)` view
modifier. For example, consider the following view:

```Swift
struct TestGestureView1: View & Inspectable {
    @State var tapped = false
        
    var body: some View {
        let gesture = TapGesture()
            .onEnded { _ in self.tapped.toggle() }
        
        return Rectangle()
            .fill(self.tapped ? Color.blue : Color.red)
            .frame(width: 10, height: 10)
            .gesture(gesture)
    }
}
```

A test can inspect the gesture using the following code:

```Swift
func testGestureModifier() throws {
    let sut = TestGestureView1()
    let rectangle = try sut.inspect().shape(0)
    XCTAssertNoThrow(try rectangle.gesture(TapGesture.self))
}
```

A test can inspect a gesture attached to a view using the `highPriorityGesture(_:including)`
view modifier. For example, consider the following view:

```Swift
struct TestGestureView2: View & Inspectable {
    @State var tapped = false
        
    var body: some View {
        let gesture = TapGesture()
            .onEnded { _ in self.tapped.toggle() }
        
        return Rectangle()
            .fill(self.tapped ? Color.blue : Color.red)
            .frame(width: 10, height: 10)
            .highPriorityGesture(gesture)
    }
}
```

A test can inspect the gesture using the following code:

```Swift
func testHighPriorityGestureModifier() throws {
    let sut = TestGestureView2()
    let rectangle = try sut.inspect().shape(0)
    XCTAssertNoThrow(try rectangle.highPriorityGesture(TapGesture.self))
}
```

A test can inspect a gesture attached using the `simultaneousGesture(_:including)`
view modifier. For example, consider the following view:

```Swift
struct TestGestureView3: View & Inspectable {
    @State var tapped = false
        
    var body: some View {
        let gesture = TapGesture()
            .onEnded { _ in self.tapped.toggle() }
        
        return Rectangle()
            .fill(self.tapped ? Color.blue : Color.red)
            .frame(width: 10, height: 10)
            .simultaneousGesture(gesture)
    }
}
```

A test can inspect the gesture using the following code:

```Swift
func testSimultaneousGestureModifier() throws {
    let sut = TestGestureView3()
    let rectangle = try sut.inspect().shape(0)
    XCTAssertNoThrow(try rectangle.simultaneousGesture(TapGesture.self))
}
```

### **Gesture Mask**

A test can inspect the mask used when a gesture was attached to a view hierarchy. For example,
consider the following view:

```Swift
struct TestGestureView9: View & Inspectable {
    @State var tapped = false
        
    var body: some View {
        let gesture = TapGesture()
            .onEnded { _ in self.tapped.toggle() }
        
        return Rectangle()
            .fill(self.tapped ? Color.blue : Color.red)
            .frame(width: 10, height: 10)
            .gesture(gesture, including: .gesture)
    }
}
```

A test can inspect the mask using the following code:

```Swift
func testGestureMask() throws {
    let sut = TestGestureView9()
    let gesture = try sut.inspect().shape(0).gesture(TapGesture.self)
    XCTAssertEqual(try gesture.gestureMask(), .gesture)
}
```

### **Gesture Properties**

A test can inspect the properties of a gesture attached to a view. For example, consider the
following view:

```Swift
struct TestGestureView4: View {
    @State var isDragging = false
    
    var body: some View {
        let drag = DragGesture(minimumDistance: 20, coordinateSpace: .global)
            .onChanged { _ in self.isDragging = true }
            .onEnded { _ in self.isDragging = false }
                    
        return Rectangle()
            .fill(self.isDragging ? Color.blue : Color.red)
            .frame(width: 10, height: 10)
            .gesture(drag)
    }
}
```

A test can inspect the gesture using the following code:

```Swift
func testTestGestureModifier() throws {
    let sut = TestGestureView()
    let rectangle = try sut.inspect().shape(0)
    let gesture = try rectangle.gesture(DragGesture.self).gestureProperties()
    XCTAssertEqual(gesture.minimumDistance, 20)
    XCTAssertEqual(gesture.coordinateSpace, .global)
}
```

### **Invoking Gesture Updating Callback**

A test can invoke the updating callbacks added to a gesture. For example, consider the following
view:

```Swift
struct TestGestureView5: View & Inspectable {
    @GestureState var isDetectingLongPress = false

    internal let inspection = Inspection<Self>()
    internal let publisher = PassthroughSubject<Void, Never>()

    var body: some View {
        let press = LongPressGesture(minimumDuration: 1)
            .updating($isDetectingLongPress) { currentState, gestureState, transaction in
                gestureState = currentState
            }

        return Circle()
            .fill(isDetectingLongPress ? Color.yellow : Color.green)
            .frame(width: 100, height: 100, alignment: .center)
            .gesture(press)
            .onReceive(inspection.notice) { self.inspection.visit(self, $0) }
            .onReceive(publisher) { }
    }
}
```

A test can invoke the updating callback for the gesture used by `TestGestureView5` using the
following code:

```Swift
func testTestGestureUpdating() throws {
    let sut = TestGestureView5()
    let exp1 = sut.inspection.inspect { view in
        XCTAssertEqual(try view.actualView().isDetectingLongPress, false)
        XCTAssertEqual(try view.shape(0).fillShapeStyle(Color.self), Color.green)
        let gesture = try view.shape(0).gesture(LongPressGesture.self)
        let value = LongPressGesture.Value(finished: true)
        var state: Bool = false
        var transaction = Transaction()
        try gesture.gestureCallUpdating(value: value, state: &state, transaction: &transaction)
        sut.publisher.send()
    }

    let exp2 = sut.inspection.inspect(onReceive: sut.publisher) { view in
        XCTAssertEqual(try view.shape(0).fillShapeStyle(Color.self), Color.green)
    }

    ViewHosting.host(view: sut)
    wait(for: [exp1, exp2], timeout: 0.1)
}
```

In this test, the first inspection invokes the updating callback. However, in the context of this
inspection, the changes resulting from the change in the `isDetectingLongPress` are not
visible. Thus, it is necessary to perform another inspection.

The `gestureCallUpdating(value:state:transaction:)` method calls all updating
callbacks added to a gesture in the order the callbacks were added to the gesture using the
gesture's `updating(_:body:)` method.

Note, a `@GestureState` property wrapper updates the property while the user performs a
gesture and reset the property back to its initial state when the gesture ends. While 
**ViewInspector** provides the means to invoke the updating callbacks added to a gesture, 
the the callback is not actually performing the gesture, and hence `@GestureState` properties
alway read as their initital state.


### **Invoking Gesture Changed Callback**

A test can invoke the changed callbacks added to a gesture. For example, consider the following
view:

```Swift
struct TestGestureView6: View & Inspectable {
    @GestureState var isDetectingLongPress = false
    @State var totalNumberOfTaps = 0

    internal let inspection = Inspection<Self>()
    internal let publisher = PassthroughSubject<Void, Never>()

    var press: some Gesture {
        LongPressGesture(minimumDuration: 1)
            .updating($isDetectingLongPress) { currentState, gestureState, transaction in
                gestureState = currentState
            }
            .onChanged { _ in
                totalNumberOfTaps += 1
            }

    }

    var body: some View {
        VStack {
            Text("\(totalNumberOfTaps)")
                .font(.largeTitle)

            Circle()
                .fill(isDetectingLongPress ? Color.yellow : Color.green)
                .frame(width: 100, height: 100, alignment: .center)
                .gesture(press)
        }
        .onReceive(inspection.notice) { self.inspection.visit(self, $0) }
        .onReceive(publisher) { }
    }
}
```

A test can invoke the changed callback for the gesture used by `TestGestureView6` using the 
following code:

```Swift
func testTestGestureChanged() throws {
    let sut = TestGestureView6()
    let exp1 = sut.inspection.inspect { view in
        XCTAssertEqual(try view.actualView().totalNumberOfTaps, 0)
        XCTAssertEqual(try view.vStack().text(0).string(), "0")
        let gesture = try view.vStack().shape(1).gesture(LongPressGesture.self)
        let value = LongPressGesture.Value(finished: true)
        try gesture.gestureCallChanged(value: value)
        sut.publisher.send()
    }

    let exp2 = sut.inspection.inspect(onReceive: sut.publisher) { view in
        XCTAssertEqual(try view.actualView().totalNumberOfTaps, 1)
        XCTAssertEqual(try view.vStack().text(0).string(), "1")
    }

    ViewHosting.host(view: sut)
    wait(for: [exp1, exp2], timeout: 0.1)
}
```

In this test, the first inspection invokes the changed callback. However, in the context of this
inspection, the changes resulting from the change in the `totalNumberOfTaps` are not
visible. Thus, it is necessary to perform another inspection.

The `gestureCallChanged(value:)` method calls all changed callbacks added to a gesture 
in the order the callbacks were added to the gesture using the gesture's `onChanged(_:body:)`
method.

### **Invoking Gesture Ended Callback**

A test can invoke the ended callbacks added to a gesture. For example, consider the following
view:

```Swift
struct TestGestureView7: View & Inspectable {
    @GestureState var isDetectingLongPress = false
    @State var totalNumberOfTaps = 0
    @State var doneCounting = false
    
    internal let inspection = Inspection<Self>()
    internal let publisher = PassthroughSubject<Void, Never>()

    var body: some View {
        let press = LongPressGesture(minimumDuration: 1)
            .updating($isDetectingLongPress) { currentState, gestureState, transaction in
                gestureState = currentState
            }.onChanged { _ in
                self.totalNumberOfTaps += 1
            }
            .onEnded { _ in
                self.doneCounting = true
            }
        
        return VStack {
            Text("\(totalNumberOfTaps)")
                .font(.largeTitle)
            
            Circle()
                .fill(doneCounting ? Color.red : isDetectingLongPress ? Color.yellow : Color.green)
                .frame(width: 100, height: 100, alignment: .center)
                .gesture(doneCounting ? nil : press)
        }
        .onReceive(inspection.notice) { self.inspection.visit(self, $0) }
        .onReceive(publisher) { }
    }
}
```

A test can invoke the changed callback for the gesture used by `TestGestureView7` using the 
following code:

```Swift
func testTestGestureEnded() throws {
    let sut = TestGestureView7()
    let exp1 = sut.inspection.inspect { view in
        XCTAssertEqual(try view.actualView().doneCounting, false)
        let circle = try view.vStack().shape(1)
        XCTAssertEqual(try circle.fillShapeStyle(Color.self), Color.green)
        let gesture = try circle.gesture(LongPressGesture.self)
        let value = LongPressGesture.Value(finished: true)
        try gesture.gestureCallEnded(value: value)
        sut.publisher.send()
    }

    let exp2 = sut.inspection.inspect(onReceive: sut.publisher) { view in
        XCTAssertEqual(try view.actualView().doneCounting, true)
        XCTAssertEqual(try view.vStack().shape(1).fillShapeStyle(Color.self), Color.red)
    }

    ViewHosting.host(view: sut)
    wait(for: [exp1, exp2], timeout: 0.1)
}
```

In this test, the first inspection invokes the changed callback. However, in the context of this
inspection, the changes resulting from the change in the `doneCounting` are not
visible. Thus, it is necessary to perform another inspection.

The `gestureCallEnded(value:)` method calls all ended callbacks added to a gesture 
in the order the callbacks were added to the gesture using the gesture's `onEnded(_:body:)`
method.

### **Gesture Keyboard Modifiers**

A test can inspect the keyboard modifiers of a gesture attached to a view. For example, 
consider the following view:

```Swift
#if os(macOS)
struct TestGestureView8: View & Inspectable {
    @State var tapped = false
        
    var body: some View {
        let gesture = TapGesture()
            .onEnded { _ in self.tapped.toggle() }
            .modifiers(.shift)
            .modifiers(.control)
        
        return Rectangle()
            .fill(self.tapped ? Color.blue : Color.red)
            .frame(width: 10, height: 10)
            .gesture(gesture)
    }
}
#endif
```

A test can inspect the gesture's keyboard modifiers using the following code:

```Swift
#if os(macOS)
func testGestureModifiers() throws {
    let sut = TestGestureView8()
    let gesture = try sut.inspect().shape(0).gesture(TapGesture.self)
    XCTAssertEqual(try gesture.gestureModifiers(), [.shift, .control])
}
#endif
```

Observe that `gestureModifiers()` finds all keyboard combined with a gesture and returns
the aggregated `EventModifiers`.

