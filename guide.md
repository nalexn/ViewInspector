# Inspection guide


- [The Basics](#the-basics)
- [Views using **@Binding**](#views-using-binding)
- [Views using **@ObservedObject**](#views-using-observedobject)
- [Views using **@State**, **@Environment** or **@EnvironmentObject**](#views-using-state-environment-or-environmentobject)
- [Custom **ViewModifier**](#custom-viewmodifier)
- [Custom **ButtonStyle** or **PrimitiveButtonStyle**](#custom-buttonstyle-or-primitivebuttonstyle)
- [Custom **LabelStyle**](#custom-labelstyle)
- [Custom **GroupBoxStyle**](#custom-groupboxstyle)
- [Custom **ToggleStyle**](#custom-togglestyle)
- [Custom **ProgressViewStyle**](#custom-progressviewstyle)

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

Custom `ViewModifier` has to be tested independently from the main hierarchy. An example:

```swift
struct MyViewModifier: ViewModifier {
    
    func body(content: Self.Content) -> some View {
        content
            .padding(.top, 15)
    }
}
```

We can take a slightly modified approach #1 described above:

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

There is no need for the `ViewModifier` to conform to `Inspectable` in the tests. Here is how you'd verify that `MyViewModifier` applies the padding:

```swift
func testViewModifier() {
    var sut = MyViewModifier()
    let exp = XCTestExpectation(description: #function)
    sut.didAppear = { body in
        body.inspect { view in
            XCTAssertEqual(try view.padding().top, 15)
        }
        ViewHosting.expel()
        exp.fulfill()
    }
    let view = EmptyView().modifier(sut)
    ViewHosting.host(view: view)
    wait(for: [exp], timeout: 0.1)
}
```
Please note that you cannot get access to the hierarchy behind the `content` of `ViewModifier`, that is `try view.emptyView()` in this test would not work: the outer hierarchy has to be inspected from the parent's view.

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
    let sut = TestProgressViewStyle()
    XCTAssertEqual(try sut.inspect(fractionCompleted: nil).vStack().styleConfigurationLabel(0).brightness(), 3)
    XCTAssertEqual(try sut.inspect(fractionCompleted: nil).vStack().styleConfigurationCurrentValueLabel(1).blur().radius, 5)
    XCTAssertEqual(try sut.inspect(fractionCompleted: 0.42).vStack().text(2).string(), "Completed: 42%")
}
```
