<h1 align="center">ViewInspector 🕵️‍♂️ for SwiftUI</h1>

<span align="center">
  
![Platform](https://img.shields.io/badge/platform-iOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20watchOS-lightgrey) [![Build Status](https://travis-ci.com/nalexn/ViewInspector.svg?branch=master)](https://travis-ci.com/nalexn/ViewInspector) [![codecov](https://codecov.io/gh/nalexn/ViewInspector/branch/master/graph/badge.svg)](https://codecov.io/gh/nalexn/ViewInspector)

</span>

**ViewInspector** is a library for unit testing SwiftUI views.
It allows for traversing a view hierarchy at runtime providing direct access to the underlying `View` structs.

## Why?

SwiftUI view is a function of state. We could provide it with the input, but were unable to verify the output... Until now!

## Helpful links

* **[Inspection guide](guide.md)**
* **[SwiftUI API coverage](readiness.md)**

## Use cases

### 1. Search the view of a specific type or condition

Use one of the `find` functions to quickly locate a specific view or assert there are none of such:

```swift
try sut.inspect().find(button: "Back")

try sut.inspect().findAll(ViewType.Text.self,
                          where: { try $0.attributes().isBold() })
```

Check out [this section](guide.md#dynamic-query-with-find) in the guide for the reference.

### 2. Read the inner state of the standard views

Standard SwiftUI views are no longer a black box:

```swift
let sut = Text("Completed by \(72.51, specifier: "%.1f")%").font(.caption)

let string = try sut.inspect().text().string(locale: Locale(identifier: "es"))
XCTAssertEqual(string, "Completado por 72,5%")

XCTAssertEqual(try sut.inspect().text().attributes().font(), .caption)
```

Each view has its own set of inspectable parameters, you can refer to the [API coverage](readiness.md) document to see what's available for a particular SwiftUI view.

### 3. Verify your custom view's state

Obtain a copy of your custom view with actual state and references from the hierarchy of any depth:

```swift
let sut = try view.inspect().find(CustomView.self).actualView()
XCTAssertTrue(sut.viewModel.isUserLoggedIn)
```

The library can operate with various types of the view's state, such as `@Binding`, `@State`, `@ObservedObject` and `@EnvironmentObject`.

### 4. Trigger side effects

You can simulate user interaction by programmatically triggering system-controls callbacks:

```swift
try sut.inspect().find(button: "Close").tap()

let list = try view.inspect().list()
try list[5].view(RowItemView.self).callOnAppear()
```

The library provides helpers for writing asynchronous tests for views with callbacks.

## FAQs

### Which views and modifiers are supported?

Check out the [API coverage](readiness.md). There is currently almost full support for SwiftUI v1 API, the v2 and v3 support is under active development.

### Is it using private APIs?

**ViewInspector** is using official Swift reflection API to dissect the view structures. So it'll be production-friendly even if you could somehow ship the test target to the production.

### How do I add it to my Xcode project?

Assure you're adding the framework to your unit-test target. **Do NOT** add it to the main build target.

#### Swift Package Manager

`https://github.com/nalexn/ViewInspector`

#### Carthage

`github "nalexn/ViewInspector"`

#### CocoaPods

`pod 'ViewInspector'`

### How do I use it in my project?

Please refer to the [Inspection guide](guide.md). You can also check out my other [project](https://github.com/nalexn/clean-architecture-swiftui) that harnesses the **ViewInspector** for testing the entire UI.

### Other questions, concerns or suggestions?

Ping me on [Twitter](https://twitter.com/nallexn) or just submit an issue or a pull request on Github.

---

[![blog](https://img.shields.io/badge/blog-github-blue)](https://nalexn.github.io/?utm_source=nalexn_github) [![venmo](https://img.shields.io/badge/%F0%9F%8D%BA-Venmo-brightgreen)](https://venmo.com/nallexn)
