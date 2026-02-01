# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

ViewInspector is a Swift library for unit testing SwiftUI views. It uses Swift reflection to traverse view hierarchies at runtime, providing access to underlying View structs, their state, and enabling programmatic interaction (tap buttons, toggle switches, etc.).

## Build & Test Commands

```bash
# Build the package
swift build

# Run all tests
swift test

# Run a specific test class
swift test --filter ViewInspectorTests.TextTests

# Run a specific test method
swift test --filter "testStringValue"

# List all available tests
swift test list
```

## Architecture

### Core Components

**Inspector** (`Sources/ViewInspector/Inspector.swift`)
- Static utility for reflection-based view inspection
- Uses `Mirror` to navigate SwiftUI view internals
- Key methods: `attribute()`, `unwrap()`, `typeName()`, `viewsInContainer()`

**Content & Medium** (`Sources/ViewInspector/BaseTypes.swift`)
- `Content` wraps view + metadata (`Medium`)
- `Medium` tracks `viewModifiers[]` and `transitiveViewModifiers[]` separately
- Modifiers searched in reverse order (most recent first)

**InspectableView<View>** (`Sources/ViewInspector/InspectableView.swift`)
- Generic wrapper that provides the public inspection API
- Maintains parent reference and path for error reporting
- Type parameter `View` must conform to `BaseViewType`

### Key Protocols

- `BaseViewType` - Base for all view types, defines `typePrefix` for matching
- `KnownViewType` - Internal, adds `childViewsBuilder()` and `supplementaryViewsBuilder()`
- `SingleViewContent` - For views with one child (AnyView, GeometryReader)
- `MultipleViewContent` - For views with N children (HStack, VStack, List)
- `SupplementaryChildren` - For non-standard children (label views, etc.)

### Adding Support for a New View Type

1. Create `Sources/ViewInspector/SwiftUI/NewView.swift`
2. Define `extension ViewType { struct NewView: KnownViewType { ... } }`
3. Set `typePrefix` to match SwiftUI's internal type name
4. Implement `SingleViewContent` or `MultipleViewContent`
5. Add extraction extension on `InspectableView`
6. Register in `ViewSearchIndex` if needed
7. Add corresponding tests in `Tests/ViewInspectorTests/SwiftUI/NewViewTests.swift`

### Adding Modifier Support

1. Extend `InspectableView` with a getter method
2. Use `modifierAttribute(modifierName:path:type:call:)` helper
3. Modifier name must match SwiftUI's internal modifier type

## Testing Patterns

Tests in this project use a custom `XCTAssertThrows` instead of `XCTAssertThrowsError` (enforced by SwiftLint).

Async view testing requires `ViewHosting.host(view:)` and callback-based inspection via `didAppear` or `Inspection<Self>` pattern.

## Code Style

- SwiftLint configuration in `.swiftlint.yml`
- Line length warning at 130 chars, error at 200
- Minimum identifier length: 2 characters

## Skills

### /new-api-support

Use `/new-api-support <entity_name>` to add introspection support for a SwiftUI API. The skill guides through:
1. Locating the API in the iOS SDK and cataloging all related overloads
2. Determining appropriate file placement
3. Reverse engineering internal structure via `Inspector.print()`
4. Implementing introspection code with proper `@available` attributes
5. Adding comprehensive tests
6. Updating `readiness.md`
