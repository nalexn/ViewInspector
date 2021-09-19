# System popup views

- [Alert](#alert)
- [ActionSheet](#actionsheet)
- [Sheet](#sheet)
- [FullScreenCover](#fullscreencover)
- [Popover](#popover)

These five types of views have many in common, so is their inspection mechanism. Due to limited capabilities of what can be achieved in reflection, the native SwiftUI modifiers for presenting these views (`.alert`, `.actionSheet`, `.sheet`, `.fullScreenCover`, `.popover`) cannot be inspected as-is by the ViewInspector.

This section discusses how you still can gain the full access to the internals of these views by adding a couple of code snippets to your source code while not making ViewInspector a dependency for the main target.

*Note*: ViewInspector fully supports `confirmationDialog` inspection without any code tweaking.

## `Alert`

If you're using `alert` functions added in iOS 15 (those not marked as deprecated) - you're good to go.

Otherwise, you'll need to add the following snippet to your main target:

```swift
extension View {
    func alert2(isPresented: Binding<Bool>, content: @escaping () -> Alert) -> some View {
        return self.modifier(InspectableAlert(isPresented: isPresented, popupBuilder: content))
    }
}

struct InspectableAlert: ViewModifier {
    
    let isPresented: Binding<Bool>
    let popupBuilder: () -> Alert
    let onDismiss: (() -> Void)? = nil
    
    func body(content: Self.Content) -> some View {
        content.alert(isPresented: isPresented, content: popupBuilder)
    }
}
```

And tweak the code of your view to use `alert2` instead of `alert`. Feel free to use another name instead of `alert2`.

Then, add this line in your test target scope:

```swift
extension InspectableAlert: PopupPresenter { }
```

After that you'll be able to inspect the `Alert` in the tests: read the `title`, `message`, and access the buttons:

```swift
func testAlertExample() throws {
    let binding = Binding(wrappedValue: true)
    let sut = EmptyView().alert2(isPresented: binding) {
        Alert(title: Text("Title"), message: Text("Message"),
              primaryButton: .destructive(Text("Delete")),
              secondaryButton: .cancel(Text("Cancel")))
    }
    let alert = try sut.inspect().emptyView().alert()
    XCTAssertEqual(try alert.title().string(), "Title")
    XCTAssertEqual(try alert.message().string(), "Message")
    XCTAssertEqual(try alert.primaryButton().style(), .destructive)
    try sut.inspect().find(ViewType.AlertButton.self, containing: "Cancel").tap()
}
```

SwiftUI has a second variant of the `Alert` presentation API, which takes a generic `Item` parameter.

Here is the corresponding snippet for the main target:

```swift
extension View {
    func alert2<Item>(item: Binding<Item?>, content: @escaping (Item) -> Alert) -> some View where Item: Identifiable {
        return self.modifier(InspectableAlertWithItem(item: item, popupBuilder: content))
    }
}

struct InspectableAlertWithItem<Item: Identifiable>: ViewModifier {
    
    let item: Binding<Item?>
    let popupBuilder: (Item) -> Alert
    let onDismiss: (() -> Void)? = nil
    
    func body(content: Self.Content) -> some View {
        content.alert(item: item, content: popupBuilder)
    }
}
```

And for the test scope:

```swift
extension InspectableAlertWithItem: ItemPopupPresenter { }
```

Feel free to add both sets to the project as needed.

## `ActionSheet`

Just like with `Alert`, there are two APIs for showing `ActionSheet` in SwiftUI - a simple one taking a `isPresented: Binding<Bool>` parameter, and a generic version taking `item: Binding<Item?>` parameter.

#### Variant with `isPresented: Binding<Bool>` - main target snippet:

```swift
extension View {
    func actionSheet2(isPresented: Binding<Bool>, content: @escaping () -> ActionSheet) -> some View {
        return self.modifier(InspectableActionSheet(isPresented: isPresented, popupBuilder: content))
    }
}

struct InspectableActionSheet: ViewModifier {
    
    let isPresented: Binding<Bool>
    let popupBuilder: () -> ActionSheet
    let onDismiss: (() -> Void)? = nil
    
    func body(content: Self.Content) -> some View {
        content.actionSheet(isPresented: isPresented, content: popupBuilder)
    }
}
```

Test target:

```swift
extension InspectableActionSheet: PopupPresenter { }
```

#### Variant with `item: Binding<Item?>` - main target snippet:

```swift
extension View {
    func actionSheet2<Item>(item: Binding<Item?>, content: @escaping (Item) -> ActionSheet) -> some View where Item: Identifiable {
        return self.modifier(InspectableActionSheetWithItem(item: item, popupBuilder: content))
    }
}

struct InspectableActionSheetWithItem<Item: Identifiable>: ViewModifier {
    
    let item: Binding<Item?>
    let popupBuilder: (Item) -> ActionSheet
    let onDismiss: (() -> Void)? = nil
    
    func body(content: Self.Content) -> some View {
        content.actionSheet(item: item, content: popupBuilder)
    }
}
```

Test target:

```swift
extension InspectableActionSheetWithItem: ItemPopupPresenter { }
```

Make sure to use `actionSheet2` in your view's body (or a different name of your choice).

## `Sheet`

Similarly to the `Alert` and `ActionSheet`, there are two APIs for presenting the `Sheet` thus two sets of snippets to add to the project, depending on your needs.

#### Variant with `isPresented: Binding<Bool>` - main target snippet:

```swift
extension View {
    func sheet2<Sheet>(isPresented: Binding<Bool>, onDismiss: (() -> Void)? = nil, @ViewBuilder content: @escaping () -> Sheet
    ) -> some View where Sheet: View {
        return self.modifier(InspectableSheet(isPresented: isPresented, onDismiss: onDismiss, popupBuilder: content))
    }
}

struct InspectableSheet<Sheet>: ViewModifier where Sheet: View {
    
    let isPresented: Binding<Bool>
    let onDismiss: (() -> Void)?
    let popupBuilder: () -> Sheet
    
    func body(content: Self.Content) -> some View {
        content.sheet(isPresented: isPresented, onDismiss: onDismiss, content: popupBuilder)
    }
}
```

Test target:

```swift
extension InspectableSheet: PopupPresenter { }
```

#### Variant with `item: Binding<Item?>` - main target snippet:

```swift
extension View {
    func sheet2<Item, Sheet>(item: Binding<Item?>, onDismiss: (() -> Void)? = nil, content: @escaping (Item) -> Sheet
    ) -> some View where Item: Identifiable, Sheet: View {
        return self.modifier(InspectableSheetWithItem(item: item, onDismiss: onDismiss, popupBuilder: content))
    }
}

struct InspectableSheetWithItem<Item, Sheet>: ViewModifier where Item: Identifiable, Sheet: View {
    
    let item: Binding<Item?>
    let onDismiss: (() -> Void)?
    let popupBuilder: (Item) -> Sheet
    
    func body(content: Self.Content) -> some View {
        content.sheet(item: item, onDismiss: onDismiss, content: popupBuilder)
    }
}
```

Test target:

```swift
extension InspectableSheetWithItem: ItemPopupPresenter { }
```

Don't forget that you'll need to use `sheet2` in place of `sheet` in your views.

## `FullScreenCover`

Similarly to the `Alert` and `Sheet`, there are two APIs for presenting the `FullScreenCover` thus two sets of snippets to add to the project, depending on your needs.

#### Variant with `isPresented: Binding<Bool>` - main target snippet:

```swift
extension View {
    func fullScreenCover2<FullScreenCover>(isPresented: Binding<Bool>, onDismiss: (() -> Void)? = nil, @ViewBuilder content: @escaping () -> FullScreenCover
    ) -> some View where FullScreenCover: View {
        return self.modifier(InspectableFullScreenCover(isPresented: isPresented, onDismiss: onDismiss, popupBuilder: content))
    }
}

struct InspectableFullScreenCover<FullScreenCover>: ViewModifier where FullScreenCover: View {
    
    let isPresented: Binding<Bool>
    let onDismiss: (() -> Void)?
    let popupBuilder: () -> FullScreenCover

    func body(content: Self.Content) -> some View {
        content.fullScreenCover(isPresented: isPresented, onDismiss: onDismiss, content: popupBuilder)
    }
}
```

Test target:

```swift
extension InspectableFullScreenCover: PopupPresenter { }
```

#### Variant with `item: Binding<Item?>` - main target snippet:

```swift
extension View {
    func fullScreenCover2<Item, FullScreenCover>(item: Binding<Item?>, onDismiss: (() -> Void)? = nil, content: @escaping (Item) -> FullScreenCover
    ) -> some View where Item: Identifiable, FullScreenCover: View {
        return self.modifier(InspectableFullScreenCoverWithItem(item: item, onDismiss: onDismiss, popupBuilder: content))
    }
}

struct InspectableFullScreenCoverWithItem<Item, FullScreenCover>: ViewModifier where Item: Identifiable, FullScreenCover: View {
    
    let item: Binding<Item?>
    let onDismiss: (() -> Void)?
    let popupBuilder: (Item) -> FullScreenCover

    func body(content: Self.Content) -> some View {
        content.fullScreenCover(item: item, onDismiss: onDismiss, content: popupBuilder)
    }
}
```

Test target:

```swift
extension InspectableFullScreenCoverWithItem: ItemPopupPresenter { }
```

Don't forget that you'll need to use `fullScreenCover2` in place of `fullScreenCover` in your views.

## `Popover`

#### Variant with `isPresented: Binding<Bool>` - main target snippet:

```swift
extension View {
    func popover2<Popover>(isPresented: Binding<Bool>,
                           attachmentAnchor: PopoverAttachmentAnchor = .rect(.bounds),
                           arrowEdge: Edge = .top,
                           @ViewBuilder content: @escaping () -> Popover
    ) -> some View where Popover: View {
        return self.modifier(InspectablePopover(
            isPresented: isPresented,
            attachmentAnchor: attachmentAnchor,
            arrowEdge: arrowEdge,
            popupBuilder: content))
    }
}

struct InspectablePopover<Popover>: ViewModifier where Popover: View {
    
    let isPresented: Binding<Bool>
    let attachmentAnchor: PopoverAttachmentAnchor
    let arrowEdge: Edge
    let popupBuilder: () -> Popover
    let onDismiss: (() -> Void)? = nil
    
    func body(content: Self.Content) -> some View {
        content.popover(isPresented: isPresented, attachmentAnchor: attachmentAnchor,
                        arrowEdge: arrowEdge, content: popupBuilder)
    }
}
```

Test target:

```swift
extension InspectablePopover: PopupPresenter { }
```

#### Variant with `item: Binding<Item?>` - main target snippet:

```swift
extension View {
    func popover2<Item, Popover>(item: Binding<Item?>,
                                 attachmentAnchor: PopoverAttachmentAnchor = .rect(.bounds),
                                 arrowEdge: Edge = .top,
                                 content: @escaping (Item) -> Popover
    ) -> some View where Item: Identifiable, Popover: View {
        return self.modifier(InspectablePopoverWithItem(
            item: item,
            attachmentAnchor: attachmentAnchor,
            arrowEdge: arrowEdge,
            popupBuilder: content))
    }
}

struct InspectablePopoverWithItem<Item, Popover>: ViewModifier where Item: Identifiable, Popover: View {
    
    let item: Binding<Item?>
    let attachmentAnchor: PopoverAttachmentAnchor
    let arrowEdge: Edge
    let popupBuilder: (Item) -> Popover
    let onDismiss: (() -> Void)? = nil
    
    func body(content: Self.Content) -> some View {
        content.popover(item: item, attachmentAnchor: attachmentAnchor,
                        arrowEdge: arrowEdge, content: popupBuilder)
    }
}
```

Test target:

```swift
extension InspectablePopoverWithItem: ItemPopupPresenter { }
```

Don't forget that you'll need to use `popover2` in place of `popover` in your views.