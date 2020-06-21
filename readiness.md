# ViewInspector readiness list

This document reflects the current status of the [ViewInspector](https://github.com/nalexn/ViewInspector) framework: which `Views` and `Modifiers` are available for inspection.

### Denotations

| Status | Meaning |
|:---:|---|
|:white_check_mark:| Full inspection support with access to the underlying values or callbacks |
|:heavy_check_mark:| Not inspectable itself but does not block inspection of the underlying hierarchy |
|:x:| Blocks inspection of the underlying hierarchy |

## View Types

| Status | View | Inspectable Attributes |
|:---:|---|---|
|:white_check_mark:| AngularGradient | `gradient: Gradient`, `center: UnitPoint`, `startAngle: Angle`, `endAngle: Angle` |
|:white_check_mark:| AnyView | `contained view` |
|:white_check_mark:| Button | `contained view`, `tap()` |
|:white_check_mark:| ConditionalContent | `contained view` |
|:white_check_mark:| SwiftUI Custom View | `actualView: CustomView`, `viewBuilder container` |
|:white_check_mark:| SwiftUI Custom @ViewBuilder | `actualView: CustomView` |
|:white_check_mark:| UIViewRepresentable | `uiView: UIView` |
|:white_check_mark:| UIViewControllerRepresentable | `viewController: UIViewController` |
|:white_check_mark:| DatePicker | `contained view` |
|:white_check_mark:| Divider | |
|:white_check_mark:| EditButton | `editMode: Binding<EditMode>?` |
|:white_check_mark:| EmptyView | |
|:white_check_mark:| EquatableView | `contained view` |
|:white_check_mark:| ForEach | `contained view` |
|:white_check_mark:| Form | `contained view` |
|:white_check_mark:| GeometryReader | `contained view` |
|:white_check_mark:| Group | `contained view` |
|:white_check_mark:| GroupBox | `contained view` |
|:white_check_mark:| HSplitView | `contained view` |
|:white_check_mark:| HStack | `contained view` |
|:white_check_mark:| Image | `imageName: String?`, `(ui,ns,cg)Image: (UI,NS,CG)Image`, `orientation: Image.Orientation`, `scale: CGFloat`, `label view` |
|:white_check_mark:| LinearGradient | `gradient: Gradient`, `startPoint: UnitPoint`, `endPoint: UnitPoint` |
|:white_check_mark:| List | `contained view` |
|:white_check_mark:| MenuButton | `contained view`, `label view` |
|:white_check_mark:| ModifiedContent | `contained view` |
|:white_check_mark:| NavigationLink | `contained view`, `label view`, `isActive: Bool`, `activate()`, `deactivate()` |
|:white_check_mark:| NavigationView | `contained view` |
|:white_check_mark:| OptionalContent | `contained view` |
|:white_check_mark:| PasteButton | `supportedTypes: [String]`|
|:white_check_mark:| Picker | `contained view`, `label view` |
|:white_check_mark:| RadialGradient | `gradient: Gradient`, `center: UnitPoint`, `startRadius: CGFloat`, `endRadius: CGFloat` |
|:white_check_mark:| ScrollView | `contained view`, `contentInsets: EdgeInsets` |
|:white_check_mark:| Section | `contained view` |
|:white_check_mark:| SecureField | `contained view`, `callOnCommit()` |
|:white_check_mark:| Shape | `func path(in rect: CGRect) -> Path`, `inset: CGFloat`, `offset: CGSize`, `scale: (x: CGFloat, y: CGFloat, anchor: UnitPoint)`, `rotation: (angle: Angle, anchor: UnitPoint)`, `transform: CGAffineTransform`, `size: CGSize`, `strokeStyle: StrokeStyle`, `trim: (from: CGFloat, to: CGFloat)`, `fillShapeStyle() -> ShapeStyle`, `fillStyle: FillStyle` |
|:white_check_mark:| Slider | `contained view`, `callOnEditingChanged()` |
|:white_check_mark:| Spacer | `minLength: CGFloat?` |
|:white_check_mark:| Stepper | `contained view`, `increment()`, `decrement()`, `callOnEditingChanged()` |
|:white_check_mark:| TabView | `contained view` |
|:white_check_mark:| Text | `string: String?` |
|:white_check_mark:| TextField | `contained view`, `callOnEditingChanged()`, `callOnCommit()` |
|:white_check_mark:| Toggle | `contained view` |
|:white_check_mark:| TouchBar | `contained view`, `touchBarID: String` |
|:white_check_mark:| VSplitView | `contained view` |
|:white_check_mark:| VStack | `contained view` |
|:white_check_mark:| ZStack | `contained view` |

---

## View Modifiers

### Sizing a View

| Status | Modifier |
|:---:|---|
|:white_check_mark:| `func frame(width: CGFloat?, height: CGFloat?, alignment: Alignment) -> View` |
|:white_check_mark:| `func frame(minWidth: CGFloat?, idealWidth: CGFloat?, maxWidth: CGFloat?, minHeight: CGFloat?, idealHeight: CGFloat?, maxHeight: CGFloat?, alignment: Alignment) -> View` |
|:white_check_mark:| `func fixedSize() -> View` |
|:white_check_mark:| `func fixedSize(horizontal: Bool, vertical: Bool) -> View` |
|:white_check_mark:| `func layoutPriority(Double) -> View` |

### Positioning a View

| Status | Modifier |
|:---:|---|
|:white_check_mark:| `func position(CGPoint) -> View` |
|:white_check_mark:| `func position(x: CGFloat, y: CGFloat) -> View` |
|:white_check_mark:| `func offset(CGSize) -> View` |
|:white_check_mark:| `func offset(x: CGFloat, y: CGFloat) -> View` |
|:white_check_mark:| `func edgesIgnoringSafeArea(Edge.Set) -> View` |
|:white_check_mark:| `func coordinateSpace<T>(name: T) -> View` |

### Aligning Views

| Status | Modifier |
|:---:|---|
|:heavy_check_mark:| `func alignmentGuide(HorizontalAlignment, computeValue: (ViewDimensions) -> CGFloat) -> View` |
|:heavy_check_mark:| `func alignmentGuide(VerticalAlignment, computeValue: (ViewDimensions) -> CGFloat) -> View` |

### Adjusting the Padding of a View

| Status | Modifier |
|:---:|---|
|:white_check_mark:| `func padding(CGFloat) -> View` |
|:white_check_mark:| `func padding(EdgeInsets) -> View` |
|:white_check_mark:| `func padding(Edge.Set, CGFloat?) -> View` |

### Layering Views

| Status | Modifier |
|:---:|---|
|:white_check_mark:| `func overlay<Overlay>(Overlay, alignment: Alignment) -> View` |
|:white_check_mark:| `func background<Background>(Background, alignment: Alignment) -> View` |
|:white_check_mark:| `func zIndex(Double) -> View` |

### Masking and Clipping Views

| Status | Modifier |
|:---:|---|
|:white_check_mark:| `func clipped(antialiased: Bool) -> View` |
|:white_check_mark:| `func clipShape<S>(S, style: FillStyle) -> View` |
|:white_check_mark:| `func cornerRadius(CGFloat, antialiased: Bool) -> View` |
|:white_check_mark:| `func mask<Mask>(Mask) -> View` |

### Scaling Views

| Status | Modifier |
|:---:|---|
|:white_check_mark:| `func scaledToFill() -> View` |
|:white_check_mark:| `func scaledToFit() -> View` |
|:white_check_mark:| `func scaleEffect(CGFloat, anchor: UnitPoint) -> View` |
|:white_check_mark:| `func scaleEffect(CGSize, anchor: UnitPoint) -> View` |
|:white_check_mark:| `func scaleEffect(x: CGFloat, y: CGFloat, anchor: UnitPoint) -> View` |
|:white_check_mark:| `func aspectRatio(CGFloat?, contentMode: ContentMode) -> View` |
|:white_check_mark:| `func aspectRatio(CGSize, contentMode: ContentMode) -> View` |
|:white_check_mark:| `func imageScale(Image.Scale) -> View` |

### Rotating and Transforming Views

| Status | Modifier |
|:---:|---|
|:white_check_mark:| `func rotationEffect(Angle, anchor: UnitPoint) -> View` |
|:white_check_mark:| `func rotation3DEffect(Angle, axis: (x: CGFloat, y: CGFloat, z: CGFloat), anchor: UnitPoint, anchorZ: CGFloat, perspective: CGFloat) -> View` |
|:white_check_mark:| `func projectionEffect(ProjectionTransform) -> View` |
|:white_check_mark:| `func transformEffect(CGAffineTransform) -> View` |

### Adjusting Text in a View

| Status | Modifier |
|:---:|---|
|:heavy_check_mark:| `func keyboardType(UIKeyboardType) -> View` |
|:heavy_check_mark:| `func font(Font?) -> View` |
|:heavy_check_mark:| `func lineLimit(Int?) -> View` |
|:heavy_check_mark:| `func lineSpacing(CGFloat) -> View` |
|:heavy_check_mark:| `func multilineTextAlignment(TextAlignment) -> View` |
|:heavy_check_mark:| `func minimumScaleFactor(CGFloat) -> View` |
|:heavy_check_mark:| `func truncationMode(Text.TruncationMode) -> View` |
|:heavy_check_mark:| `func allowsTightening(Bool) -> View` |
|:heavy_check_mark:| `func textContentType(UITextContentType?) -> View` |
|:heavy_check_mark:| `func textContentType(WKTextContentType?) -> View` |
|:heavy_check_mark:| `func flipsForRightToLeftLayoutDirection(Bool) -> View` |
|:heavy_check_mark:| `func autocapitalization(UITextAutocapitalizationType) -> View` |
|:heavy_check_mark:| `func disableAutocorrection(Bool?) -> View` |

### Adding Animations to a View

| Status | Modifier |
|:---:|---|
|:heavy_check_mark:| `func animation(Animation?) -> View` |
|:heavy_check_mark:| `func animation<V>(Animation?, value: V) -> View` |
|:white_check_mark:| `func transition(AnyTransition) -> View` |

### Handling View Taps and Gestures

| Status | Modifier |
|:---:|---|
|:white_check_mark:| `func onTapGesture(count: Int, perform: () -> Void) -> View` |
|:white_check_mark:| `func onLongPressGesture(minimumDuration: Double, maximumDistance: CGFloat, pressing: ((Bool) -> Void)?, perform: () -> Void) -> View` |
|:heavy_check_mark:| `func gesture<T>(T, including: GestureMask) -> View` |
|:heavy_check_mark:| `func highPriorityGesture<T>(T, including: GestureMask) -> View` |
|:heavy_check_mark:| `func simultaneousGesture<T>(T, including: GestureMask) -> View` |
|:heavy_check_mark:| `func digitalCrownRotation<V>(Binding<V>) -> View` |
|:heavy_check_mark:| `func digitalCrownRotation<V>(Binding<V>, from: V, through: V, by: V.Stride?, sensitivity: DigitalCrownRotationalSensitivity, isContinuous: Bool, isHapticFeedbackEnabled: Bool) -> View` |
|:white_check_mark:| `func transaction((inout Transaction) -> Void) -> View` |

### Handling View Events

| Status | Modifier |
|:---:|---|
|:white_check_mark:| `func onAppear(perform: (() -> Void)?) -> View` |
|:white_check_mark:| `func onDisappear(perform: (() -> Void)?) -> View` |
|:white_check_mark:| `func onCutCommand(perform: (() -> [NSItemProvider])?) -> View` |
|:white_check_mark:| `func onCopyCommand(perform: (() -> [NSItemProvider])?) -> View` |
|:heavy_check_mark:| `func onPasteCommand(of: [String], perform: ([NSItemProvider]) -> Void) -> View` |
|:heavy_check_mark:| `func onPasteCommand<Payload>(of: [String], validator: ([NSItemProvider]) -> Payload?, perform: (Payload) -> Void) -> View` |
|:white_check_mark:| `func onDeleteCommand(perform: (() -> Void)?) -> View` |
|:white_check_mark:| `func onMoveCommand(perform: ((MoveCommandDirection) -> Void)?) -> View` |
|:white_check_mark:| `func onExitCommand(perform: (() -> Void)?) -> View` |
|:heavy_check_mark:| `func onPlayPauseCommand(perform: (() -> Void)?) -> View` |
|:white_check_mark:| `func onCommand(Selector, perform: (() -> Void)?) -> View` |
|:heavy_check_mark:| `func deleteDisabled(Bool) -> View` |
|:heavy_check_mark:| `func moveDisabled(Bool) -> View` |

### Handling Publisher Events

| Status | Modifier |
|:---:|---|
|:heavy_check_mark:| `func onReceive<P>(P, perform: (P.Output) -> Void) -> View` |

### Handling View Hover and Focus

| Status | Modifier |
|:---:|---|
|:heavy_check_mark:| `func onHover(perform: (Bool) -> Void) -> View` |
|:white_check_mark:| `func focusable(Bool, onFocusChange: (Bool) -> Void) -> View` |

### Supporting Drag and Drop in Views

| Status | Modifier |
|:---:|---|
|:heavy_check_mark:| `func onDrag(() -> NSItemProvider) -> View` |
|:heavy_check_mark:| `func onDrop(of: [String], delegate: DropDelegate) -> View` |
|:heavy_check_mark:| `func onDrop(of: [String], isTargeted: Binding<Bool>?, perform: ([NSItemProvider], CGPoint) -> Bool) -> View` |
|:heavy_check_mark:| `func onDrop(of: [String], isTargeted: Binding<Bool>?, perform: ([NSItemProvider]) -> Bool) -> View` |
|:heavy_check_mark:| `func itemProvider(Optional<() -> NSItemProvider?>) -> View` |

### Presenting Additional Views

| Status | Modifier |
|:---:|---|
|:heavy_check_mark:| `func sheet<Content>(isPresented: Binding<Bool>, onDismiss: (() -> Void)?, content: () -> Content) -> View` |
|:heavy_check_mark:| `func sheet<Item, Content>(item: Binding<Item?>, onDismiss: (() -> Void)?, content: (Item) -> Content) -> View` |
|:heavy_check_mark:| `func actionSheet(isPresented: Binding<Bool>, content: () -> ActionSheet) -> View` |
|:heavy_check_mark:| `func actionSheet<T>(item: Binding<T?>, content: (T) -> ActionSheet) -> View` |
|:heavy_check_mark:| `func alert(isPresented: Binding<Bool>, content: () -> Alert) -> View` |
|:heavy_check_mark:| `func alert<Item>(item: Binding<Item?>, content: (Item) -> Alert) -> View` |
|:heavy_check_mark:| `func popover<Content>(isPresented: Binding<Bool>, attachmentAnchor: PopoverAttachmentAnchor, arrowEdge: Edge, content: () -> Content) -> View` |
|:heavy_check_mark:| `func popover<Item, Content>(item: Binding<Item?>, attachmentAnchor: PopoverAttachmentAnchor, arrowEdge: Edge, content: (Item) -> Content) -> View` |

### Setting View Colors

| Status | Modifier |
|:---:|---|
|:heavy_check_mark:| `func foregroundColor(Color?) -> View` |
|:heavy_check_mark:| `func accentColor(Color?) -> View` |

### Adopting View Color Schemes

| Status | Modifier |
|:---:|---|
|:heavy_check_mark:| `func colorScheme(ColorScheme) -> View` |
|:heavy_check_mark:| `func preferredColorScheme(ColorScheme?) -> View` |

### Applying Graphical Effects to a View

| Status | Modifier |
|:---:|---|
|:white_check_mark:| `func blur(radius: CGFloat, opaque: Bool) -> View` |
|:white_check_mark:| `func opacity(Double) -> View` |
|:white_check_mark:| `func brightness(Double) -> View` |
|:white_check_mark:| `func contrast(Double) -> View` |
|:white_check_mark:| `func colorInvert() -> View` |
|:white_check_mark:| `func colorMultiply(Color) -> View` |
|:white_check_mark:| `func saturation(Double) -> View` |
|:white_check_mark:| `func grayscale(Double) -> View` |
|:white_check_mark:| `func hueRotation(Angle) -> View` |
|:white_check_mark:| `func luminanceToAlpha() -> View` |
|:white_check_mark:| `func shadow(color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) -> View` |
|:white_check_mark:| `func border<S>(S, width: CGFloat) -> View` |

### Compositing Views

| Status | Modifier |
|:---:|---|
|:white_check_mark:| `func blendMode(BlendMode) -> View` |
|:heavy_check_mark:| `func compositingGroup() -> View` |
|:heavy_check_mark:| `func drawingGroup(opaque: Bool, colorMode: ColorRenderingMode) -> View` |
|:heavy_check_mark:| `func labelsHidden() -> View` |
|:heavy_check_mark:| `func defaultWheelPickerItemHeight(CGFloat) -> View` |
|:heavy_check_mark:| `func horizontalRadioGroupLayout() -> View` |
|:heavy_check_mark:| `func controlSize(ControlSize) -> View` |

### Styling Views

| Status | Modifier |
|:---:|---|
|:heavy_check_mark:| `func buttonStyle<S>(S) -> View` |
|:heavy_check_mark:| `func menuButtonStyle<S>(S) -> View` |
|:heavy_check_mark:| `func pickerStyle<S>(S) -> View` |
|:heavy_check_mark:| `func datePickerStyle<S>(S) -> View` |
|:heavy_check_mark:| `func textFieldStyle<S>(S) -> View` |
|:heavy_check_mark:| `func toggleStyle<S>(S) -> View` |
|:heavy_check_mark:| `func listStyle<S>(S) -> View` |
|:heavy_check_mark:| `func navigationViewStyle<S>(S) -> View` |

### Configuring a List View

| Status | Modifier |
|:---:|---|
|:heavy_check_mark:| `func listRowInsets(EdgeInsets?) -> View` |
|:heavy_check_mark:| `func listRowBackground<V>(V?) -> View` |
|:heavy_check_mark:| `func listRowPlatterColor(Color?) -> View` |
|:white_check_mark:| `func tag<V>(V) -> View` |

### Configuring Navigation and Status Bar Views

| Status | Modifier |
|:---:|---|
|:heavy_check_mark:| `func navigationBarTitle(Text) -> View` |
|:heavy_check_mark:| `func navigationBarTitle(Text, displayMode: NavigationBarItem.TitleDisplayMode) -> View` |
|:heavy_check_mark:| `func navigationBarTitle(LocalizedStringKey) -> View` |
|:heavy_check_mark:| `func navigationBarTitle<S>(S) -> View` |
|:heavy_check_mark:| `func navigationBarTitle(LocalizedStringKey, displayMode: NavigationBarItem.TitleDisplayMode) -> View` |
|:heavy_check_mark:| `func navigationBarHidden(Bool) -> View` |
|:heavy_check_mark:| `func statusBar(hidden: Bool) -> View` |

### Configuring Navigation and Tab Bar Item Views

| Status | Modifier |
|:---:|---|
|:heavy_check_mark:| `func navigationBarBackButtonHidden(Bool) -> View` |
|:heavy_check_mark:| `func navigationBarItems<L>(leading: L) -> View` |
|:heavy_check_mark:| `func navigationBarItems<L, T>(leading: L, trailing: T) -> View` |
|:heavy_check_mark:| `func navigationBarItems<T>(trailing: T) -> View` |
|:white_check_mark:| `func tabItem<V>(() -> V) -> View` |

### Configuring Context Menu Views

| Status | Modifier |
|:---:|---|
|:heavy_check_mark:| `func contextMenu<MenuItems>(ContextMenu<MenuItems>?) -> View` |
|:heavy_check_mark:| `func contextMenu<MenuItems>(menuItems: () -> MenuItems) -> View` |

### Configuring Touch Bar Views

| Status | Modifier |
|:---:|---|
|:white_check_mark:| `func touchBar<Content>(content: () -> Content) -> View` |
|:white_check_mark:| `func touchBar<Content>(TouchBar<Content>) -> View` |
|:white_check_mark:| `func touchBarItemPrincipal(Bool) -> View` |
|:white_check_mark:| `func touchBarCustomizationLabel(Text) -> View` |
|:white_check_mark:| `func touchBarItemPresence(TouchBarItemPresence) -> View` |

### Hiding and Disabling Views

| Status | Modifier |
|:---:|---|
|:white_check_mark:| `func hidden() -> View` |
|:heavy_check_mark:| `func disabled(Bool) -> View` |

### Creating Accessible Views

| Status | Modifier |
|:---:|---|
|:white_check_mark:| `func accessibility(label: Text) -> ModifiedContent<Self, AccessibilityAttachmentModifier>` |
|:white_check_mark:| `func accessibility(value: Text) -> ModifiedContent<Self, AccessibilityAttachmentModifier>` |
|:white_check_mark:| `func accessibility(hidden: Bool) -> ModifiedContent<Self, AccessibilityAttachmentModifier>` |
|:white_check_mark:| `func accessibility(identifier: String) -> ModifiedContent<Self, AccessibilityAttachmentModifier>` |
|:white_check_mark:| `func accessibility(selectionIdentifier: AnyHashable) -> ModifiedContent<Self, AccessibilityAttachmentModifier>` |

### Customizing Accessibility Interactions of a View

| Status | Modifier |
|:---:|---|
|:white_check_mark:| `func accessibility(hint: Text) -> ModifiedContent<Self, AccessibilityAttachmentModifier>` |
|:white_check_mark:| `func accessibility(activationPoint: UnitPoint) -> ModifiedContent<Self, AccessibilityAttachmentModifier>` |
|:white_check_mark:| `func accessibility(activationPoint: CGPoint) -> ModifiedContent<Self, AccessibilityAttachmentModifier>` |
|:white_check_mark:| `func accessibilityAction(AccessibilityActionKind, () -> Void) -> ModifiedContent<Self, AccessibilityAttachmentModifier>` |
|:heavy_check_mark:| `func accessibilityAction(named: Text, () -> Void) -> ModifiedContent<Self, AccessibilityAttachmentModifier>` |
|:white_check_mark:| `func accessibilityAdjustableAction((AccessibilityAdjustmentDirection) -> Void) -> ModifiedContent<Self, AccessibilityAttachmentModifier>` |
|:white_check_mark:| `func accessibilityScrollAction((Edge) -> Void) -> ModifiedContent<Self, AccessibilityAttachmentModifier>` |

### Customizing Accessibility Navigation of a View

| Status | Modifier |
|:---:|---|
|:heavy_check_mark:| `func accessibilityElement(children: AccessibilityChildBehavior) -> View` |
|:heavy_check_mark:| `func accessibility(addTraits: AccessibilityTraits) -> ModifiedContent<Self, AccessibilityAttachmentModifier>` |
|:heavy_check_mark:| `func accessibility(removeTraits: AccessibilityTraits) -> ModifiedContent<Self, AccessibilityAttachmentModifier>` |
|:white_check_mark:| `func accessibility(sortPriority: Double) -> ModifiedContent<Self, AccessibilityAttachmentModifier>` |

### Setting View Preferences

| Status | Modifier |
|:---:|---|
|:heavy_check_mark:| `func preference<K>(key: K.Type, value: K.Value) -> View` |
|:heavy_check_mark:| `func transformPreference<K>(K.Type, (inout K.Value) -> Void) -> View` |
|:heavy_check_mark:| `func anchorPreference<A, K>(key: K.Type, value: Anchor<A>.Source, transform: (Anchor<A>) -> K.Value) -> View` |
|:heavy_check_mark:| `func transformAnchorPreference<A, K>(key: K.Type, value: Anchor<A>.Source, transform: (inout K.Value, Anchor<A>) -> Void) -> View` |
|:heavy_check_mark:| `func onPreferenceChange<K>(K.Type, perform: (K.Value) -> Void) -> View` |
|:x:| `func backgroundPreferenceValue<Key, T>(Key.Type, (Key.Value) -> T) -> View` |
|:x:| `func overlayPreferenceValue<Key, T>(Key.Type, (Key.Value) -> T) -> View` |

### Setting the Environment Values of a View

| Status | Modifier |
|:---:|---|
|:heavy_check_mark:| `func environment<V>(WritableKeyPath<EnvironmentValues, V>, V) -> View` |
|:heavy_check_mark:| `func environmentObject<B>(B) -> View` |
|:heavy_check_mark:| `func transformEnvironment<V>(WritableKeyPath<EnvironmentValues, V>, transform: (inout V) -> Void) -> View` |

### Configuring a View for Hit Testing

| Status | Modifier |
|:---:|---|
|:white_check_mark:| `func allowsHitTesting(Bool) -> View` |
|:white_check_mark:| `func contentShape<S>(S, eoFill: Bool) -> View` |

### Configuring View Previews

| Status | Modifier |
|:---:|---|
|:white_check_mark:| `func previewDevice(PreviewDevice?) -> View` |
|:white_check_mark:| `func previewDisplayName(String?) -> View` |
|:white_check_mark:| `func previewLayout(PreviewLayout) -> View` |

### Inspecting Views

| Status | Modifier |
|:---:|---|
|:white_check_mark:| `func id<ID>(ID) -> View` |
|:white_check_mark:| `func equatable() -> EquatableView<Self>` |

### Implementing View Modifiers

| Status | Modifier |
|:---:|---|
|:heavy_check_mark:| `func modifier<T>(T) -> ModifiedContent<Self, T>` |
