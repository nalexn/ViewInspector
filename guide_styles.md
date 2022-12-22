# Styles

- [Custom **ButtonStyle** or **PrimitiveButtonStyle**](#custom-buttonstyle-or-primitivebuttonstyle)
- [Custom **LabelStyle**](#custom-labelstyle)
- [Custom **GroupBoxStyle**](#custom-groupboxstyle)
- [Custom **ToggleStyle**](#custom-togglestyle)
- [Custom **ProgressViewStyle**](#custom-progressviewstyle)
- [Custom Styles](#custom-styles)

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
appearance for all views that apply the custom style in a view hierarchy.

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
part of the view's hierarchy. The following view modifier illustrates how to accomplish this:

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
hierarchy:

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

A test can verify the style applied to a view hierarchy. For example:

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

## Other topics

- [Main guide](guide.md)
- [Gestures](guide_gestures.md)
