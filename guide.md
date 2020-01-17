# Inspection guide


- [The Basics](#the-basics)
- [Views using **@ObservedObject**](#views-using-observedobject)
- [Views using **@State**, **@Environment** or **@EnvironmentObject**](#views-using-state-environment-or-environmentobject)
- [Views using **@Binding**](#views-using-binding)
- [More fine-grained test configuration](#more-fine-grained-test-configuration)
- [Views using multiple state sources](#views-using-multiple-state-sources)

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

## Views using `@ObservedObject`

**ViewInspector** provides full support for such views, so you can inspect them without any intervention in the source code.

Unlike the views using `@State`, `@Environment` or `@EnvironmentObject`, the state changes inside `@ObservedObject` can be evaluated with synchronous tests. You may consider, however, using the asynchronous approach described below, just for the sake of the tests consistency.

## Views using `@State`, `@Environment` or `@EnvironmentObject`

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
    let publisher: PassthroughSubject<Bool, Never>
    
    var didAppear: ((Self) -> Void)?
    var didReceiveValue: ((Self) -> Void)?
    
    var body: some View {
        Text(flag ? "True" : "False")
        .onReceive(publisher) { value in
            self.flag = value
            self.didReceiveValue?(self)
        }
        .onAppear { self.didAppear?(self) }
    }
}
```

The test may look like this:

```swift
final class ContentViewTests: XCTestCase {

    func testPublisherChangesText() {
        let publisher = PassthroughSubject<Bool, Never>()
        var sut = ContentView(publisher: publisher)
        let exp1 = sut.on(\.didAppear) { view in
            let text = try view.inspect().text().string()
            XCTAssertEqual(text, "False")
        }
        let exp2 = sut.on(\.didReceiveValue) { view in
            let text = try view.inspect().text().string()
            XCTAssertEqual(text, "True")
        }
        ViewHosting.host(view: sut)
        publisher.send(true)
        wait(for: [exp1, exp2], timeout: 0.1)
    }
}
```

I should warn that async dispatch from inside the callback disconnects the `view` struct from the SwiftUI state context, so any asynchronous access to the state won't work as expected (except for the `@ObservedObject`, which is immune to this effect).

## Views using `@Binding`

For the views using the `@Binding` property wrapper:

```swift
struct ContentView: View {

    @Binding var flag: Bool
    var didAppear: ((Self) -> Void)?
    
    var body: some View {
        Button(action: {
            self.flag.toggle()
        }, label: { Text(flag ? "True" : "False") })
        .onAppear { self.didAppear?(self) }
    }
}
```

**ViewInspector** provides a helper initializer that you can use for testing such views:

```swift
func testBindingValueChanges() {

    let flag = Binding<Bool>(wrappedValue: false)
    
    var sut = ContentView(flag: flag)
    let exp = sut.on(\.didAppear) { view in
        XCTAssertFalse(flag.wrappedValue)
        try view.inspect().button().tap()
        XCTAssertTrue(flag.wrappedValue)
    }
    ViewHosting.host(view: sut)
    wait(for: [exp], timeout: 0.1)
}
```

## More fine-grained test configuration

The `.on(_ keyPath:)` function is a convenience method for `XCTest` framework. Alternatively, if you need more control, you can configure the callback directly on the view:

```swift
let exp = XCTestExpectation(description: "didAppear")
var sut = ContentView()
sut.didAppear = { view in
    view.inspect { content in
        // inspect the content here
    }
    ViewHosting.expel()
    exp.fulfill()
}
ViewHosting.host(view: sut)
wait(for: [exp], timeout: 0.1)
```

Note that in this case you'd need to remove the view with `ViewHosting.expel()` and complete the async test with `.fulfill()`.

The `.inspect { ... }` under the hood starts the inspection and wraps the code in the `do { ... } catch { ... }` allowing for writing more compact tests. The closure is called synchronously.

## Views using multiple state sources

For complex views relying on a combination of `@State`, `@Binding`, `@ObservedObject`, `@EnvironmentObject` or Combine's `publishers` it might be hard to catch the final view state in the `didAppear` or other callback you add. In this case you can introduce a custom view modifier that captures the view state on every view update (call of the `body`). Include the following code snippet in your build target:

```swift
extension View {
    func onUpdate<V>(_ viewCapture: @autoclosure @escaping () -> V,
                     _ callbackKeyPath: KeyPath<V, ((V) -> Void)?>) -> some View where V: View {
        modifier(ContextCatcher(viewCapture: viewCapture, callbackKeyPath: callbackKeyPath))
    }
}

private struct ContextCatcher<V>: ViewModifier where V: View {
    
    let viewCapture: () -> V
    let callbackKeyPath: KeyPath<V, ((V) -> Void)?>
    
    func body(content: Self.Content) -> some View {
        let view = viewCapture()
        view[keyPath: callbackKeyPath]?(view)
        return content.onAppear()
    }
}
```

And apply it to the target view:

```swift
struct ContentView: View {

    var didUpdate: ((Self) -> Void)?
    
    var body: some View {
        ...
        .onUpdate(self, \.didUpdate)
    }
}
```

In the tests you'll have the full access to the view's state on every `body` update:

```swift
let exp = XCTestExpectation(description: "didUpdate")
exp.expectedFulfillmentCount = 3
exp.assertForOverFulfill = true
var sut = ContentView()
var updateNumber = 0
sut.didUpdate = { view in
    updateNumber += 1
    view.inspect { content in
        // inspect the content here considering the updateNumber
    }
    if updateNumber == exp.expectedFulfillmentCount {
        ViewHosting.expel()
    }
    exp.fulfill()
}
ViewHosting.host(view: sut)
wait(for: [exp], timeout: 0.1)
```