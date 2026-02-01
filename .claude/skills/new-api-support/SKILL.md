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

### Step 2: Determine File Placement

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

### Step 3: Reverse Engineering Investigation

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

### Step 4: Implement Introspection Support

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

### Step 5: Add Tests

**Test file structure:**

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

**For modifiers:**

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

**Run tests incrementally:**
```bash
# Run specific test
swift test --filter "NewViewTypeTests/testExtractionFromSingleViewContainer"

# Run all tests for the new type
swift test --filter "NewViewTypeTests"
```

### Step 6: Update readiness.md

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

1. **Platform-unavailable APIs** - Wrap entire test file in `#if !os(visionOS)` (or appropriate platform), not individual tests

2. **Add `@MainActor` to test class** to avoid main actor isolation warnings

3. **Don't test platform-specific default values** - They may vary across platforms. Only test explicit parameter values

4. **Compare to exact values** instead of `XCTAssertNotNil` when possible:
   ```swift
   // Good
   XCTAssertEqual(result.id, AnyHashable("testID"))

   // Avoid when exact comparison is possible
   XCTAssertNotNil(result.id)
   ```

5. **Don't duplicate tests** that test the same functionality with different values (e.g., don't need separate tests for Circle, Capsule, RoundedRectangle shapes - one is sufficient)

6. **Test missing modifier errors** - Verify error messages are correct:
   ```swift
   func testGlassEffectMissingModifierError() throws {
       let sut = EmptyView().padding()
       XCTAssertThrows(
           try sut.inspect().emptyView().glassEffect(),
           "EmptyView does not have 'glassEffect' modifier")
   }
   ```

7. **Search tests should search for child views** inside the container, not just the container itself:
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

8. **Some values can't be compared directly** - `Namespace.ID` is recreated during inspection; use `XCTAssertNotNil` with a comment explaining why
