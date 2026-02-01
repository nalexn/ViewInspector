---
name: new-api-support
description: Add introspection support for a SwiftUI API (view type, modifier, or View extension function). Use when the user wants to add support for a new SwiftUI entity to ViewInspector.
argument-hint: <entity_name>
---

# new-api-support

Add introspection support for a SwiftUI API (view type, modifier, or View extension function).

## Usage

```
/new-api-support <entity_name>
```

Where `<entity_name>` is:
- A SwiftUI struct name (e.g., `ContentUnavailableView`, `ProgressView`)
- A View extension function name (e.g., `onAppear`, `disabled`, `opacity`)
- A modifier struct name (e.g., `ScaledMetric`)

## Workflow

### Step 1: Locate and Catalog the API

**Find the API in the local iOS SDK** (prefer local over network):

```bash
# Find SwiftUI interface files in Xcode SDK
find /Applications/Xcode.app/Contents/Developer/Platforms -name "SwiftUI.swiftmodule" -type d 2>/dev/null | head -5

# Search for the entity in SwiftUI interfaces
grep -r "<entity_name>" /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk/System/Library/Frameworks/SwiftUI.framework/Modules/SwiftUI.swiftmodule/*.swiftinterface 2>/dev/null | head -50

# For macOS SDK
grep -r "<entity_name>" /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/System/Library/Frameworks/SwiftUI.framework/Modules/SwiftUI.swiftmodule/*.swiftinterface 2>/dev/null | head -50
```

**Catalog ALL related APIs:**
- For functions: Find all overloads (same name, different parameters)
- For structs: Find the struct definition AND any View extension functions that return this type
- Note ALL `@available` attributes for each API variant

Example catalog format:
```
Entity: .buttonStyle(_:)
Type: View extension function
Related APIs:
  1. func buttonStyle<S>(_ style: S) -> some View where S : ButtonStyle
     @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
  2. func buttonStyle<S>(_ style: S) -> some View where S : PrimitiveButtonStyle
     @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
```

### Step 2: Research Usage Context

**Understand HOW the API is meant to be used** by researching its typical context:

1. **Search for documentation and usage patterns:**
   - Use web search to find Apple documentation and WWDC sessions
   - Look for common usage patterns in tutorials and Stack Overflow
   - Identify which parent views/containers the API is typically used with

2. **Identify related parent/child relationships:**

   | Entity Type | Find Related Context |
   |-------------|---------------------|
   | View inside container | Which container views typically hold this view? (e.g., `Tab` goes inside `TabView`) |
   | View modifier | Which views is this modifier typically applied to? (e.g., `subscriptionStoreButtonLabel` applies to `SubscriptionStoreView`) |
   | Container-specific modifier | Which container makes this modifier meaningful? (e.g., `listRowBackground` on views inside `List`) |
   | Style modifier | Which view type does this style affect? (e.g., `buttonStyle` on `Button`) |

3. **Document the context for test design:**

   Example context analysis:
   ```
   Entity: Tab
   Type: View
   Typical Context: Used as direct child of TabView
   Related APIs: TabView, tabItem (deprecated predecessor)
   Test Structure: Tab should be tested INSIDE TabView hierarchy

   Entity: subscriptionStoreButtonLabel
   Type: View modifier
   Typical Context: Applied to SubscriptionStoreView
   Related APIs: SubscriptionStoreView, SubscriptionStoreButton
   Test Structure: Apply modifier to SubscriptionStoreView, not EmptyView
   ```

4. **Check for container-dependent behavior:**
   - Some modifiers only work in specific contexts (e.g., `listRowInsets` only meaningful in `List`)
   - Some views only function inside specific parents (e.g., `Section` in `List` or `Form`)
   - Test in the correct context to ensure real-world usability

### Step 3: Determine File Placement

**For new View types** (structs like `ProgressView`, `ContentUnavailableView`):
- Create new file: `Sources/ViewInspector/SwiftUI/<ViewName>.swift`
- Create test file: `Tests/ViewInspectorTests/SwiftUI/<ViewName>Tests.swift`

**For View modifiers/functions**, find the appropriate existing file by category:

| Category | Source File | Test File |
|----------|-------------|-----------|
| Animation (.animation, .transition) | `Modifiers/AnimationModifiers.swift` | `ViewModifiers/AnimationModifiersTests.swift` |
| Configuration (.disabled, .labelsHidden) | `Modifiers/ConfigurationModifiers.swift` | `ViewModifiers/ConfigurationModifiersTests.swift` |
| Environment (.environment, .environmentObject) | `Modifiers/EnvironmentModifiers.swift` | `ViewModifiers/EnvironmentModifiersTests.swift` |
| Interaction (.onTapGesture, .onAppear) | `Modifiers/InteractionModifiers.swift` | `ViewModifiers/InteractionModifiersTests.swift` |
| Positioning (.offset, .position) | `Modifiers/PositioningModifiers.swift` | `ViewModifiers/PositioningModifiersTests.swift` |
| Sizing (.frame, .fixedSize) | `Modifiers/SizingModifiers.swift` | `ViewModifiers/SizingModifiersTests.swift` |
| Text input (.keyboardType, .textContentType) | `Modifiers/TextInputModifiers.swift` | `ViewModifiers/TextInputModifiersTests.swift` |
| Transform (.rotationEffect, .scaleEffect) | `Modifiers/TransformingModifiers.swift` | `ViewModifiers/TransformingModifiersTests.swift` |
| Navigation bar (.navigationTitle) | `Modifiers/NavigationBarModifiers.swift` | - |
| Custom styles (.buttonStyle, .pickerStyle) | `Modifiers/CustomStyleModifiers.swift` | - |

Check existing files to confirm the pattern:
```bash
grep -l "similar_modifier" Sources/ViewInspector/Modifiers/*.swift
```

### Step 4: Reverse Engineering Investigation

**Create a reverse engineering test** to understand the internal structure:

```swift
import XCTest
import SwiftUI
@testable import ViewInspector

final class ReverseEngineeringTests: XCTestCase {

    func testInvestigate_<EntityName>() throws {
        // Create a simple view using the target API
        let sut = EmptyView().<targetAPI>()

        // Print the internal structure
        print("\(Inspector.print(sut) as AnyObject)")
    }
}
```

**Run the investigation test:**
```bash
swift test --filter "testInvestigate_"
```

**Analyze the output** to identify:
1. The internal modifier/view type name (e.g., `_AppearanceActionModifier`)
2. Property names and their paths (e.g., `appear`, `disappear`)
3. Nested structure for complex types
4. Whether it uses `ModifiedContent` wrapper

Example Inspector.print output:
```
EmptyView
  → _AppearanceActionModifier
      modifier: _AppearanceActionModifier
        appear: Optional<() -> ()>
          some: (Function)
        disappear: Optional<() -> ()>
          none
```

**Iterate investigation** for each API variant and parameter combination to understand all internal structures.

### Step 5: Implement Introspection Support

**For View modifiers**, add to the appropriate Modifiers file:

```swift
@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView {

    // For simple value extraction
    func <modifierName>() throws -> <ReturnType> {
        return try modifierAttribute(
            modifierName: "<InternalModifierName>",  // From Inspector.print
            path: "modifier|<propertyPath>",         // Path to the value
            type: <ReturnType>.self,
            call: "<modifierName>")
    }

    // For callback invocation
    func call<CallbackName>() throws {
        let callback = try modifierAttribute(
            modifierName: "<InternalModifierName>",
            path: "modifier|<callbackPath>",
            type: (() -> Void).self,
            call: "call<CallbackName>")
        callback()
    }
}
```

**For new View types**, create the full ViewType structure:

```swift
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public extension ViewType {

    struct NewViewType: KnownViewType {
        public static let typePrefix: String = "NewViewType"  // From Inspector.print
        public static var namespacedPrefixes: [String] {
            ["SwiftUI.NewViewType"]
        }
    }
}

// MARK: - Content Extraction

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension ViewType.NewViewType: SingleViewContent {  // or MultipleViewContent

    public static func child(_ content: Content) throws -> Content {
        return try Inspector.attribute(path: "content", value: content.view)
    }
}

// MARK: - Extraction from View hierarchy

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public extension InspectableView where View == ViewType.NewViewType {

    // Add attribute getters based on Inspector.print analysis
    func someAttribute() throws -> SomeType {
        return try Inspector.attribute(
            path: "attributePath",
            value: content.view,
            type: SomeType.self)
    }
}

// MARK: - Global View hierarchy access

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public extension InspectableView {

    func newViewType(_ index: Int? = nil) throws -> InspectableView<ViewType.NewViewType> {
        return try contentForModifierLookup.newViewType(parent: self, index: index)
    }
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
internal extension Content {

    func newViewType(parent: UnwrappedView, index: Int?) throws
        -> InspectableView<ViewType.NewViewType> {
        let call = "newViewType(\(index == nil ? "" : "\(index!)"))"
        return try .init(try Inspector.attribute(path: "content", value: view),
                         parent: parent, call: call, index: index)
    }
}
```

### Step 6: Add Tests

**IMPORTANT: Use contextual test structure based on Step 2 research.**

Tests should reflect real-world usage patterns, not just technical functionality.

**For views that belong inside specific containers:**

```swift
import XCTest
import SwiftUI
@testable import ViewInspector

// Example: Tab is meant to be used inside TabView
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
final class TabTests: XCTestCase {

    // Test extraction in proper context (inside TabView)
    func testTabInsideTabView() throws {
        let sut = TabView {
            Tab("Home", systemImage: "house") {
                Text("Home Content")
            }
            Tab("Settings", systemImage: "gear") {
                Text("Settings Content")
            }
        }
        let tab = try sut.inspect().tabView().tab(0)
        XCTAssertEqual(try tab.labelView().text().string(), "Home")
    }

    // Test searching for content inside Tab inside TabView
    func testSearchForContentInsideTab() throws {
        let sut = TabView {
            Tab("Home", systemImage: "house") {
                Text("Home Content")
            }
        }
        XCTAssertEqual(
            try sut.inspect().find(text: "Home Content").pathToRoot,
            "tabView().tab(0).text()")
    }
}
```

**For modifiers that apply to specific view types:**

```swift
// Example: subscriptionStoreButtonLabel applies to SubscriptionStoreView
@available(iOS 17.0, macOS 14.0, *)
final class SubscriptionModifiersTests: XCTestCase {

    func testSubscriptionStoreButtonLabel() throws {
        let sut = SubscriptionStoreView(productIDs: ["com.app.subscription"])
            .subscriptionStoreButtonLabel(.multiline)
        let label = try sut.inspect().subscriptionStoreView().subscriptionStoreButtonLabel()
        XCTAssertEqual(label, .multiline)
    }
}

// Example: listRowBackground applies to views inside List
@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class ListModifiersTests: XCTestCase {

    func testListRowBackgroundInsideList() throws {
        let sut = List {
            Text("Row")
                .listRowBackground(Color.red)
        }
        let background = try sut.inspect().list().text(0).listRowBackground()
        // Verify the background color
    }
}
```

**For style modifiers, test with the view type they style:**

```swift
// Example: buttonStyle applies to Button
@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class ButtonStyleTests: XCTestCase {

    func testButtonStyleOnButton() throws {
        let sut = Button("Tap") { }
            .buttonStyle(.borderedProminent)
        let style = try sut.inspect().button().buttonStyle()
        // Verify style properties
    }
}
```

**Generic test file structure (when no specific context applies):**

```swift
import XCTest
import SwiftUI
@testable import ViewInspector

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
final class NewViewTypeTests: XCTestCase {

    // Test basic extraction
    func testExtractionFromSingleViewContainer() throws {
        let view = AnyView(NewViewType())
        XCTAssertNoThrow(try view.inspect().anyView().newViewType())
    }

    // Test attribute inspection
    func testSomeAttributeInspection() throws {
        let sut = NewViewType(someParam: .value)
        let value = try sut.inspect().newViewType().someAttribute()
        XCTAssertEqual(value, .value)
    }

    // Test in view hierarchy
    func testSearch() throws {
        let view = HStack { NewViewType() }
        XCTAssertEqual(try view.inspect().find(ViewType.NewViewType.self).pathToRoot,
                       "hStack().newViewType(0)")
    }
}
```

**For generic modifiers (not container-specific):**

```swift
@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class SomeModifierTests: XCTestCase {

    func testModifierApplication() throws {
        let sut = EmptyView().someModifier(value: 42)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }

    func testModifierValueInspection() throws {
        let sut = EmptyView().someModifier(value: 42)
        let value = try sut.inspect().emptyView().someModifier()
        XCTAssertEqual(value, 42)
    }
}
```

**Run tests incrementally (headless - fast iteration):**
```bash
# Run specific test
swift test --filter "NewViewTypeTests/testExtractionFromSingleViewContainer"

# Run all tests for the new type
swift test --filter "NewViewTypeTests"
```

**Final verification on platform simulators:**

Headless `swift test` is fast and suitable for development iteration, but **final verification must run on actual platform simulators** for all platforms the API supports.

Based on the API's `@available` attributes, verify tests pass on each supported platform:

```bash
# iOS Simulator
xcodebuild test -scheme ViewInspector -destination 'platform=iOS Simulator,name=iPhone 16'

# tvOS Simulator
xcodebuild test -scheme ViewInspector -destination 'platform=tvOS Simulator,name=Apple TV'

# macOS
xcodebuild test -scheme ViewInspector -destination 'platform=macOS'

# visionOS Simulator
xcodebuild test -scheme ViewInspector -destination 'platform=visionOS Simulator,name=Apple Vision Pro'

# watchOS - SPECIAL: Uses separate Xcode project
xcodebuild test -project .watchOS/watchOS.xcodeproj -scheme watchOS -destination 'platform=watchOS Simulator,name=Apple Watch Series 10 (46mm)'
```

**Platform testing requirements:**
- If API is `@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)` → test on all four platforms
- If API is `@available(iOS 15.0, *)` with `@available(macOS, unavailable)` → only test iOS
- watchOS is peculiar: always use `.watchOS/watchOS.xcodeproj` instead of the main package

**Quick platform matrix check:**
```bash
# List available simulators
xcrun simctl list devices available
```

### Step 7: Update readiness.md

Add the new API to `readiness.md` in the appropriate section:

**For View types**, add to the "View Types" table:
```markdown
|:white_check_mark:| NewViewType | `attribute1`, `attribute2`, `containedView` |
```

**For Modifiers**, add to the "View Modifiers" table:
```markdown
|:white_check_mark:| `.someModifier(value:)` | `someModifier() -> Type` |
```

Maintain alphabetical order within each section.

### Step 8: Update unsupported_swiftui_apis.md

After adding support for a new API, check if `unsupported_swiftui_apis.md` exists in the repository root and remove the entry for the newly supported API:

```bash
# Check if the file exists
ls unsupported_swiftui_apis.md

# Search for the API entry
grep -n "<entity_name>" unsupported_swiftui_apis.md
```

**Remove the entry** from the appropriate section:
- For view types: Remove from "View Types - Not Supported" or "View Types - Partial Support"
- For modifiers: Remove from "View Modifiers - Not Supported"
- For property wrappers: Remove from "Property Wrappers - Not Supported"
- For partial support completions: Remove from "View Types - Partial Support" if now fully supported

**Also remove from Quick Reference** if the API was listed there:
```markdown
# Remove lines like:
/new-api-support Gauge
/new-api-support "Group(subviews:)"
```

If the file doesn't exist, skip this step.

## Important Notes

1. **Always check `@available` attributes** - Copy them exactly from the SDK and apply to all introspection code and tests

2. **Use `XCTAssertThrows`** instead of `XCTAssertThrowsError` (enforced by SwiftLint)

3. **Handle platform differences** - Some APIs have different availability on iOS/macOS/tvOS/watchOS. Use `#if os()` when needed

4. **Test all overloads** - Each function variant may have different internal structure

5. **Modifier path format** - Use `|` as path separator: `"modifier|property|nestedProperty"`

6. **Common internal type prefixes**:
   - `_` prefix: Internal SwiftUI types (e.g., `_AppearanceActionModifier`)
   - `Modified` suffix: Wrapped content (e.g., `ModifiedContent`)

7. **For callbacks/closures** - Store them via `try Inspector.attribute()` then invoke

8. **Registration in ViewSearchIndex** - For new view types, check if registration in `ViewSearchIndex.swift` is needed for `find()` to work

## Public API Design Principles

1. **Never return `Any` from public APIs** - Consumers need typed values they can work with

2. **Prefer returning SwiftUI types** over `String`, `Any`, or custom types:
   - If a public SwiftUI type exists (like `GlassEffectTransition`), return it
   - When internal types (e.g., `_GlassEffectTransition`) can't be cast to public types, investigate if you can map string descriptions to public type values

3. **Create wrapper types for complex modifier parameters**:
   - Instead of multiple methods like `glassEffectTintColor()` and `glassEffectShape()`, create a wrapper `ViewType.GlassEffect` with methods `tintColor()`, `shape()`, etc.
   - The wrapper holds the internal config and provides typed accessors
   - Example pattern:
   ```swift
   public extension ViewType {
       struct GlassEffect {
           private let config: Any
           public func tintColor() throws -> SwiftUI.Color? { ... }
           public func shape<S>(_ type: S.Type) throws -> S where S: SwiftUI.Shape { ... }
       }
   }
   ```
   - Note: When inside ViewType namespace, use fully qualified names like `SwiftUI.Color` and `SwiftUI.Shape` to avoid conflicts with other ViewType members

4. **Add `BinaryEquatable` conformance to the public library API** (not just tests) for SwiftUI types that consumers may want to compare in their tests

## Investigation Techniques

1. **`Inspector.print()` returns a String** - Must wrap with `print()` to see output:
   ```swift
   print(Inspector.print(someValue))  // Correct
   Inspector.print(someValue)         // Wrong - output not visible
   ```

2. **Investigate chained method calls** to understand behavior:
   - Chaining same method (e.g., `.tint(.red).tint(.blue)`) typically overwrites - last value wins
   - Chaining different methods (e.g., `.tint(.red).interactive(true)`) preserves all values
   - There's usually no internal "combined" structure - just single values per property

3. **Check type casting between internal and public types**:
   - Internal types like `_Glass` often cannot be cast to public types like `Glass`
   - When casting fails, extract individual properties and map them to public type values

## Test Best Practices

1. **Test in proper context** - Always test views and modifiers in their intended usage context:
   - Child views should be tested inside their parent containers (e.g., `Tab` inside `TabView`)
   - Container-specific modifiers should be tested on views inside that container (e.g., `listRowBackground` on views inside `List`)
   - Style modifiers should be tested on the view type they style (e.g., `buttonStyle` on `Button`)
   - This ensures tests validate real-world usability, not just technical extraction

2. **Platform-unavailable APIs** - Wrap entire test file in `#if !os(visionOS)` (or appropriate platform), not individual tests

3. **Add `@MainActor` to test class** to avoid main actor isolation warnings

4. **Don't test platform-specific default values** - They may vary across platforms. Only test explicit parameter values

5. **Compare to exact values** instead of `XCTAssertNotNil` when possible:
   ```swift
   // Good
   XCTAssertEqual(result.id, AnyHashable("testID"))

   // Avoid when exact comparison is possible
   XCTAssertNotNil(result.id)
   ```

6. **Don't duplicate tests** that test the same functionality with different values (e.g., don't need separate tests for Circle, Capsule, RoundedRectangle shapes - one is sufficient)

7. **Test missing modifier errors** - Verify error messages are correct:
   ```swift
   func testGlassEffectMissingModifierError() throws {
       let sut = EmptyView().padding()
       XCTAssertThrows(
           try sut.inspect().emptyView().glassEffect(),
           "EmptyView does not have 'glassEffect' modifier")
   }
   ```

8. **Search tests should search for child views** inside the container, not just the container itself:
   ```swift
   func testSearchForChildInsideContainer() throws {
       let view = VStack {
           NewContainer {
               Text("Child1")
               Text("Child2")
           }
       }
       XCTAssertEqual(
           try view.inspect().find(text: "Child2").pathToRoot,
           "vStack().newContainer(0).text(1)")
   }
   ```

9. **Some values can't be compared directly** - `Namespace.ID` is recreated during inspection; use `XCTAssertNotNil` with a comment explaining why

## Advanced Introspection Techniques

ViewInspector uses several advanced techniques to access SwiftUI's internal structures. Use these when standard `Inspector.attribute()` approaches don't work.

### 1. BinaryEquatable Protocol

**Problem**: SwiftUI types like `Font.Weight`, `ToolbarItemPlacement`, `GlassEffectTransition` don't conform to `Equatable`, making test assertions impossible.

**Solution**: `BinaryEquatable` compares raw memory bytes instead:

```swift
// In BaseTypes.swift
public protocol BinaryEquatable: Equatable { }

extension BinaryEquatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        withUnsafeBytes(of: lhs) { lhsBytes -> Bool in
            withUnsafeBytes(of: rhs) { rhsBytes -> Bool in
                lhsBytes.elementsEqual(rhsBytes)
            }
        }
    }
}

// Usage - add conformance to enable comparisons
@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
extension ToolbarItemPlacement: BinaryEquatable { }

@available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, *)
extension GlassEffectTransition: BinaryEquatable { }
```

**When to use**: For any SwiftUI type that needs equality comparison in tests but doesn't provide `Equatable`.

### 2. unsafeBitCast with Allocator Pattern

**Problem**: Many SwiftUI types (gesture values, style configurations, proxies) don't have public initializers, but tests need to create instances.

**Solution**: Create an Allocator struct matching the memory layout, then bitcast:

```swift
@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private extension GeometryProxy {
    struct Allocator48 {
        let data: (Int64, Int64, Int64, Int64, Int64, Int64) = (0, 0, 0, 0, 0, 0)
    }
    struct Allocator52 {
        let data: (Allocator48, Int32) = (.init(), 0)
    }

    init() {
        switch MemoryLayout<Self>.size {
        case 52:
            self = unsafeBitCast(Allocator52(), to: GeometryProxy.self)
        case 48:
            self = unsafeBitCast(Allocator48(), to: GeometryProxy.self)
        default:
            fatalError(MemoryLayout<Self>.actualSize())
        }
    }
}
```

**Key patterns**:
- Create multiple Allocator variants for different OS versions (struct sizes change!)
- Use `MemoryLayout<Self>.size` switch to pick the right allocator
- Use `MemoryLayout<Self>.actualSize()` in default case to discover new sizes
- Name allocators by size (e.g., `Allocator48`, `Allocator52`)

**When to use**: Creating gesture values, style configurations, proxies, `_ViewModifier_Content`, `_PreferenceValue`, etc.

### 3. Surrogate Pattern for Private Struct Access

**Problem**: Need to access internal properties of a private SwiftUI type like `SignInWithAppleButton`.

**Solution**: Create a Surrogate struct matching the memory layout, then rebind:

```swift
// The Surrogate mirrors the internal structure
extension SignInWithAppleButton {
    struct Surrogate {
        let type: ASAuthorizationAppleIDButton.ButtonType
        let onRequest: (ASAuthorizationAppleIDRequest) -> Void
        let onCompletion: (Result<ASAuthorization, Error>) -> Void
    }
}

// Access via unsafeMemoryRebind
private func buttonSurrogate() throws -> Surrogate {
    let button = try Inspector.cast(value: content.view, type: SignInWithAppleButton.self)
    return try Inspector.unsafeMemoryRebind(value: button, type: Surrogate.self)
}
```

**When to use**: When you need to access multiple internal properties or invoke internal callbacks.

### 4. unsafeMemoryRebind for Type Conversion

**Problem**: Need to convert between types with identical memory layouts (e.g., Swift 6 Sendable closures).

**Solution**: Use `Inspector.unsafeMemoryRebind`:

```swift
// In Inspector.swift
static func unsafeMemoryRebind<V, T>(value: V, type: T.Type) throws -> T {
    guard MemoryLayout<V>.size == MemoryLayout<T>.size else {
        throw InspectionError.notSupported("Unable to rebind...")
    }
    return withUnsafeBytes(of: value) { bytes in
        return bytes.baseAddress!
            .assumingMemoryBound(to: T.self).pointee
    }
}
```

**When to use**: Converting closure types with different Sendable annotations, or accessing surrogate types.

### 5. withUnsafePointer + withMemoryRebound for Binding Conversion

**Problem**: Internal enum type is wrapped in Binding but you need a different Binding type (e.g., Toggle's internal `ToggleState` enum).

**Solution**: Rebind the pointer:

```swift
// Toggle changed from Binding<Bool> to Binding<ToggleState> in iOS 16
private enum ToggleState { case on, off, mixed }

let toggleStateBinding = try Inspector.attribute(label: "_toggleState", value: content.view)
let toggleState = withUnsafePointer(to: toggleStateBinding) {
    $0.withMemoryRebound(to: Binding<ToggleState>.self, capacity: 1) {
        $0.pointee
    }
}
// Now create a Bool binding that wraps the ToggleState
return Binding(
    get: { toggleState.wrappedValue == .on },
    set: { toggleState.wrappedValue = $0 ? .on : .off }
)
```

**When to use**: When the internal binding type differs from the public API type.

### 6. withUnsafeBytes + bindMemory for Closure Invocation

**Problem**: Need to invoke a closure stored in a generic container with specific type parameters.

**Solution**: Bind the closure's memory to the expected type:

```swift
typealias Closure = (EnvironmentValues) -> ModifiedContent<V, SomeModifier>

guard let typedClosure = withUnsafeBytes(of: closure, {
    $0.bindMemory(to: Closure.self).first
}) else { throw InspectionError.typeMismatch(closure, Closure.self) }

let view = typedClosure(EnvironmentValues())
```

**When to use**: Invoking closure-based content builders like `GeometryReader`, `ScrollViewReader`, or `navigationBarItems`.

### 7. Memory Patching for Environment Injection

**Problem**: Need to inject environment objects into views that require them for inspection.

**Solution**: Scan memory for matching patterns and patch:

```swift
// In EnvironmentInjection.swift
static func inject<T>(environmentObject: AnyObject, into entity: T) -> T {
    let envObjSize = EnvObject.structSize
    var offset = MemoryLayout<T>.stride - envObjSize

    return withUnsafeBytes(of: EnvObject.Forgery(object: nil)) { reference in
        while offset >= 0 {
            var copy = entity
            withUnsafeMutableBytes(of: &copy) { bytes in
                // Check if memory at offset matches empty env object pattern
                guard bytes[offset..<offset + envObjSize].elementsEqual(reference)
                else { return }
                // Write marker to verify location
                let rawPointer = bytes.baseAddress! + offset + EnvObject.seedOffset
                let pointerToValue = rawPointer.assumingMemoryBound(to: Int.self)
                pointerToValue.pointee = -1
            }
            // Verify via reflection that we found the right location
            if let seed = try? Inspector.attribute(path: label + "|_seed", value: copy, type: Int.self),
               seed == -1 {
                // Patch with actual object
                withUnsafeMutableBytes(of: &copy) { bytes in
                    let rawPointer = bytes.baseAddress! + offset
                    let pointerToValue = rawPointer.assumingMemoryBound(to: EnvObject.Forgery.self)
                    pointerToValue.pointee = .init(object: environmentObject)
                }
                return copy
            }
            offset -= step
        }
        return entity
    }
}
```

**When to use**: This technique is already implemented in ViewInspector for environment injection. Reference it when debugging environment-related issues.

### 8. NSKeyedUnarchiver + setValue for Objective-C Types

**Problem**: Need to create instances of Objective-C types without public initializers (e.g., `ASAuthorizationAppleIDCredential`).

**Solution**: Decode from archived data and mutate with `setValue`:

```swift
public extension ASAuthorizationAppleIDCredential {
    convenience init(user: String, email: String?, fullName: PersonNameComponents?, ...) {
        // Base64-encoded archived empty instance
        let data = Data(base64Encoded: "YnBsaXN0MDD...")
        let decoder = try! NSKeyedUnarchiver(forReadingFrom: data!)
        self.init(coder: decoder)!

        // Mutate with desired values
        setValue(user, forKey: "user")
        setValue(email, forKey: "email")
        setValue(fullName, forKey: "fullName")
        // ... more properties
    }
}
```

**When to use**: Creating Objective-C class instances that need custom initialization for testing.

### 9. MemoryLayout.actualSize() Discovery Helper

**Problem**: SwiftUI struct sizes change between OS versions, breaking Allocator patterns.

**Solution**: Use a helper to discover new sizes:

```swift
internal extension MemoryLayout {
    static func actualSize() -> String {
        fatalError("New size of \(String(describing: type(of: T.self))) is \(Self.size)")
    }
}

// Usage in switch default case:
init(fractionCompleted: Double?) {
    switch MemoryLayout<Self>.size {
    case 12:
        self = unsafeBitCast(Allocator12(fractionCompleted: fractionCompleted), to: Self.self)
    case 36:
        self = unsafeBitCast(Allocator36(fractionCompleted: fractionCompleted), to: Self.self)
    default:
        fatalError(MemoryLayout<Self>.actualSize())  // "New size of ProgressViewStyleConfiguration is 48"
    }
}
```

**When to use**: Always include in Allocator pattern switch statements to detect OS changes.

### 10. String Description Mapping for Internal Enums

**Problem**: Internal enums can't be cast to public types, but their string description matches public values.

**Solution**: Map string descriptions to public enum values:

```swift
func glassEffectTransition() throws -> GlassEffectTransition {
    let kind = try modifierAttribute(
        modifierName: "GlassEffectTransitionModifier", path: "modifier|transition|kind",
        type: Any.self, call: "glassEffectTransition")

    // Internal _GlassEffectTransition can't cast to GlassEffectTransition
    // but String(describing:) reveals the case name
    let description = String(describing: kind)
    if description == "materialize" {
        return .materialize
    } else if description.hasPrefix("matchedGeometry") {
        return .matchedGeometry
    } else {
        return .identity
    }
}
```

**When to use**: When internal enums have public equivalents but casting fails.

### Quick Reference: Choosing the Right Technique

| Problem | Technique |
|---------|-----------|
| Compare non-Equatable types | BinaryEquatable |
| Create type without public init | Allocator + unsafeBitCast |
| Access private struct properties | Surrogate + unsafeMemoryRebind |
| Convert closure types | withUnsafeBytes + bindMemory |
| Convert binding types | withUnsafePointer + withMemoryRebound |
| Create Obj-C types | NSKeyedUnarchiver + setValue |
| Handle OS version changes | MemoryLayout switch + actualSize() |
| Map internal to public enum | String(describing:) mapping |
