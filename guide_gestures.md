# Gestures

SwiftUI defines a number of built-in gestures, including: `DragGesture`, `LongPressGesture`,
`MagnificationGesture`, `RotationGesture`, and `TapGesture`. An application can compose
these gestures using `ExclusiveGesture`, `SequenceGesture`, and `SimultaneousGesture`.

**ViewInspector** provides supports for both simple and composed gestures. Given the complex
nature of gestures, the following sections discuss different aspects of this support.

- [**Gesture Modifiers**](#gesture-modifiers)
- [**Gesture Mask**](#gesture-mask)
- [**Gesture Properties**](#gesture-properties)
- [**Invoking Gesture Updating Callback**](#invoking-gesture-updating-callback)
- [**Invoking Gesture Changed Callback**](#invoking-gesture-changed-callback)
- [**Invoking Gesture Ended Callback**](#invoking-gesture-ended-callback)
- [**Gesture Keyboard Modifiers**](#gesture-keyboard-modifiers)
- [**Composed Gestures**](#composed-gestures)

### **Gesture Modifiers**

A test can inspect a gesture attached to a view using the `gesture(_:including:)` view
modifier. For example, consider the following view:

```Swift
struct TestGestureView1: View {
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
struct TestGestureView2: View {
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
struct TestGestureView3: View {
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
struct TestGestureView9: View {
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
    let gesture = try rectangle.gesture(DragGesture.self).actualGesture()
    XCTAssertEqual(gesture.minimumDistance, 20)
    XCTAssertEqual(gesture.coordinateSpace, .global)
}
```

### **Invoking Gesture Updating Callback**

A test can invoke the updating callbacks added to a gesture. For example, consider the following
view:

```Swift
struct TestGestureView5: View {
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
        try gesture.callUpdating(value: value, state: &state, transaction: &transaction)
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

The `callUpdating(value:state:transaction:)` method calls all `updating`
callbacks added to a gesture in the order the callbacks were added to the gesture using the
gesture's `updating(_:body:)` method.

Note, a `@GestureState` property wrapper updates the property while the user performs a
gesture and reset the property back to its initial state when the gesture ends. While 
**ViewInspector** provides the means to invoke the updating callbacks added to a gesture, 
the callback is not actually performing the gesture, and hence `@GestureState` properties
alway read as their initital state.


### **Invoking Gesture Changed Callback**

A test can invoke the changed callbacks added to a gesture. For example, consider the following
view:

```Swift
struct TestGestureView6: View {
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
        try gesture.callOnChanged(value: value)
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

The `callOnChanged(value:)` method calls all `onChanged` callbacks added to a gesture 
in the order the callbacks were added to the gesture using the gesture's `onChanged(_:body:)`
method.

### **Invoking Gesture Ended Callback**

A test can invoke the ended callbacks added to a gesture. For example, consider the following
view:

```Swift
struct TestGestureView7: View {
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
        try gesture.callOnEnded(value: value)
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

The `callOnEnded(value:)` method calls all `onEnded` callbacks added to a gesture 
in the order the callbacks were added to the gesture using the gesture's `onEnded(_:body:)`
method.

### **Gesture Keyboard Modifiers**

A test can inspect the keyboard modifiers of a gesture attached to a view. For example, 
consider the following view:

```Swift
#if os(macOS)
struct TestGestureView8: View {
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

### **Composed Gestures**

An application can compose more complex gestures from the simple gestures that ship with
SwiftUI, including `DragGesture`, `LongPressGesture`, `MagnificationGesture`,
`RotationGesture`, and `TapGesture`. **ViewInspector** provides a number of methods to
traverse composed gestures.

If a test inspects a gesture using `gesture(_:)`, `highPriorityGesture(_:)`, or 
`simultaneousGesture(_:)`, and the gesture is a composed gesture (i.e., it is an
`ExclusiveGesture`, `SequenceGesture`, or `SimultaneousGesture`), then the test
can use the following methods for this gesture:
* `actualGesture(_:)`: To obtain the properties of the composed gesture.
* `gestureModifiers(_:)`: To obtain keyboard modifiers for the composed gesture.
* `callUpdating(value:state:transacation:)`: To invoke updating callbacks
attached to the composed gesture.
* `callOnEnded(value:)`: To invoke `onEnded` callbacks attached to the composed
gesture.

However, these methods only provide access to the composed gesture, as opposed to the
gestures in the composition. To access the gestures in the composition, consider the following
view:

```Swift
@available(iOS 13.0, macOS 11.0, tvOS 13.0, watchOS 6.0, *)
struct TestGestureView10: View {
    @State var scale: CGFloat = 1.0
    @State var angle = Angle(degrees: 0)
    
    internal let inspection = Inspection<Self>()
    internal let publisher = PassthroughSubject<Void, Never>()

    var body: some View {
        let magnificationGesture = MagnificationGesture()
            .onChanged { value in self.scale = value.magnitude }
        
        let rotationGesture = RotationGesture()
            .onChanged { value in self.angle = value }
        
        let gesture = SimultaneousGesture(magnificationGesture, rotationGesture)
        
        VStack {
            Image(systemName: "star.circle.fill")
                .font(.system(size: 200))
                .foregroundColor(Color.red)
                .gesture(gesture)
                .rotationEffect(angle)
                .scaleEffect(scale)
                .animation(.easeInOut)
                .onReceive(inspection.notice) { self.inspection.visit(self, $0) }
                .onReceive(publisher) { }
       }
    }
}
```

Think of a gesture composition as a binary tree. In this example, the view uses a gesture
composition where the root is a simultaneous gesture containing two children: a magnification
gesture and a rotation gesture. A test can inspect the first (or left) gesture of composed 
gesture using the `first(_:)` method:

```Swift
func testComposedGestureFirst() throws {
    let sut = TestGestureView10()
    let exp1 = sut.inspection.inspect { view in
        let simultaneousGesture = try view
            .vStack()
            .image(0)
            .gesture(SimultaneousGesture<MagnificationGesture, RotationGesture>.self)
        let magnificationGesture = try simultaneousGesture
            .first(MagnificationGesture.self)
        let value = MagnificationGesture.Value(2.0)
        try magnificationGesture.callOnChanged(value: value)
        sut.publisher.send()
    }
    
    let exp2 = sut.inspection.inspect { view in
        XCTAssertEqual(try view.actualView().scale, 2.0)
    }

    ViewHosting.host(view: sut)
    wait(for: [exp1, exp2], timeout: 0.1)
}
```

A test can inspect the second (or right) gesture of a composed gesture using the `second(_:)`
method:

```Swift
func testComposedGestureSecond() throws {
    let sut = TestGestureView10()
    let exp1 = sut.inspection.inspect { view in
        let simultaneousGesture = try view
            .vStack()
            .image(0)
            .gesture(SimultaneousGesture<MagnificationGesture, RotationGesture>.self)
        let rotationGesture = try simultaneousGesture
            .second(RotationGesture.self)
        let value = RotationGesture.Value(angle: Angle(degrees: 5))
        try rotationGesture.callOnChanged(value: value)
        sut.publisher.send()
    }
    
    let exp2 = sut.inspection.inspect { view in
        XCTAssertEqual(try view.actualView().angle, Angle(degrees: 5))
    }

    ViewHosting.host(view: sut)
    wait(for: [exp1, exp2], timeout: 0.1)
}
```

This method of inspecting more gesture compositions works as well. For example, the following
view uses a gesture composed of three simple gestures. While the gesture itself isn't wired 
into the view, the example is useful for demonstration purposes:

```Swift
@available(iOS 13.0, macOS 11.0, tvOS 13.0, watchOS 6.0, *)
struct TestGestureView12: View {
    
    internal let inspection = Inspection<Self>()
    internal let publisher = PassthroughSubject<Void, Never>()
    
    var body: some View {
        let rotationGesture = RotationGesture()
        let magnificationGesture = MagnificationGesture()
        let dragGesture = DragGesture()
        
        let gesture = SimultaneousGesture(
            SimultaneousGesture(magnificationGesture, rotationGesture),
            dragGesture)
        
        VStack {
            Image(systemName: "star.circle.fill")
                .font(.system(size: 200))
                .foregroundColor(Color.red)
                .gesture(gesture)
        }
        .onReceive(inspection.notice) { self.inspection.visit(self, $0) }
        .onReceive(publisher) { }
    }
}
```

The following test demonstrates how to inspect the magnification gesture contained by the
gesture composition:

```Swift
func testComposedGestureComplex() throws {
    let sut = TestGestureView12()
    let exp = sut.inspection.inspect { view in
        let outerSimultaneousGesture = try view
            .vStack()
            .image(0)
            .gesture(SimultaneousGesture<SimultaneousGesture<MagnificationGesture, RotationGesture>, DragGesture>.self)
        let innerSimultaneousGesture = try outerSimultaneousGesture.first(SimultaneousGesture<MagnificationGesture, RotationGesture>.self)
        XCTAssertNoThrow(try innerSimultaneousGesture.first(MagnificationGesture.self))
    }

    ViewHosting.host(view: sut)
    wait(for: [exp], timeout: 0.1)
}
```

## Other topics

- [Main guide](guide.md)
- [Styles](guide_styles.md)
