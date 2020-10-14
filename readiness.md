# ViewInspector readiness list

This document reflects the current status of the [ViewInspector](https://github.com/nalexn/ViewInspector) framework: which `Views` and `Modifiers` are available for inspection.

### Denotations

| Status | Meaning |
|:---:|---|
|:white_check_mark:| Full inspection support with access to the underlying values or callbacks |
|:heavy_check_mark:| Not inspectable itself but does not block inspection of the underlying hierarchy |
|:x:| Blocks inspection of the underlying hierarchy |
|:technologist:| Pending development (accepting PRs!) |

## View Types

| Status | View | Inspectable Attributes |
|:---:|---|---|
|:white_check_mark:| AngularGradient | `gradient: Gradient`, `center: UnitPoint`, `startAngle: Angle`, `endAngle: Angle` |
|:white_check_mark:| AnyView | `contained view` |
|:white_check_mark:| Button | `contained view`, `tap()` |
|:white_check_mark:| ButtonStyleConfiguration.Label | |
|:white_check_mark:| Color | `value: Color`, `rgba: (Float, Float, Float, Float)`, `name: String` |
|:technologist:| ColorPicker | |
|:white_check_mark:| ConditionalContent | `contained view` |
|:white_check_mark:| SwiftUI Custom View | `actualView: CustomView`, `viewBuilder container` |
|:white_check_mark:| SwiftUI Custom @ViewBuilder | `actualView: CustomView` |
|:white_check_mark:| UIViewRepresentable | `uiView: UIView` |
|:white_check_mark:| UIViewControllerRepresentable | `viewController: UIViewController` |
|:white_check_mark:| DatePicker | `contained view` |
|:technologist:| DisclosureGroup | |
|:white_check_mark:| Divider | |
|:white_check_mark:| EditButton | `editMode: Binding<EditMode>?` |
|:white_check_mark:| EmptyView | |
|:white_check_mark:| EquatableView | `contained view` |
|:white_check_mark:| ForEach | `contained view` |
|:white_check_mark:| Form | `contained view` |
|:technologist:| Gauge | |
|:technologist:| GaugeStyleConfiguration.CurrentValueLabel | |
|:technologist:| GaugeStyleConfiguration.Label | |
|:technologist:| GaugeStyleConfiguration.MarkedValueLabel | |
|:technologist:| GaugeStyleConfiguration.MaximumValueLabel | |
|:technologist:| GaugeStyleConfiguration.MinimumValueLabel | |
|:white_check_mark:| GeometryReader | `contained view` |
|:white_check_mark:| Group | `contained view` |
|:white_check_mark:| GroupBox | `contained view` |
|:technologist:| GroupBoxStyleConfiguration.Content | |
|:technologist:| GroupBoxStyleConfiguration.Label | |
|:white_check_mark:| HSplitView | `contained view` |
|:white_check_mark:| HStack | `contained view` |
|:white_check_mark:| Image | `imageName: String?`, `(ui,ns,cg)Image: (UI,NS,CG)Image`, `orientation: Image.Orientation`, `scale: CGFloat`, `label view` |
|:technologist:| Label | |
|:technologist:| LabelStyleConfiguration.Icon | |
|:technologist:| LabelStyleConfiguration.Title | |
|:technologist:| LazyHGrid | |
|:technologist:| LazyHStack | |
|:technologist:| LazyVGrid | |
|:technologist:| LazyVStack | |
|:white_check_mark:| LinearGradient | `gradient: Gradient`, `startPoint: UnitPoint`, `endPoint: UnitPoint` |
|:technologist:| Link | |
|:white_check_mark:| List | `contained view` |
|:technologist:| Menu | |
|:white_check_mark:| MenuButton | `contained view`, `label view` |
|:technologist:| MenuStyleConfiguration.Content | |
|:technologist:| MenuStyleConfiguration.Label | |
|:white_check_mark:| ModifiedContent | `contained view` |
|:white_check_mark:| NavigationLink | `contained view`, `label view`, `isActive: Bool`, `activate()`, `deactivate()` |
|:white_check_mark:| NavigationView | `contained view` |
|:white_check_mark:| OptionalContent | `contained view` |
|:technologist:| OutlineGroup | |
|:technologist:| OutlineSubgroupChildren | |
|:white_check_mark:| PasteButton | `supportedTypes: [String]`|
|:white_check_mark:| Picker | `contained view`, `label view` |
|:white_check_mark:| PrimitiveButtonStyleConfiguration.Label | |
|:technologist:| ProgressView | |
|:technologist:| ProgressViewStyleConfiguration.CurrentValueLabel | |
|:technologist:| ProgressViewStyleConfiguration.Label | |
|:white_check_mark:| RadialGradient | `gradient: Gradient`, `center: UnitPoint`, `startRadius: CGFloat`, `endRadius: CGFloat` |
|:white_check_mark:| ScrollView | `contained view`, `contentInsets: EdgeInsets` |
|:technologist:| ScrollViewReader | |
|:white_check_mark:| Section | `contained view` |
|:white_check_mark:| SecureField | `contained view`, `callOnCommit()` |
|:white_check_mark:| Shape | `func path(in rect: CGRect) -> Path`, `inset: CGFloat`, `offset: CGSize`, `scale: (x: CGFloat, y: CGFloat, anchor: UnitPoint)`, `rotation: (angle: Angle, anchor: UnitPoint)`, `transform: CGAffineTransform`, `size: CGSize`, `strokeStyle: StrokeStyle`, `trim: (from: CGFloat, to: CGFloat)`, `fillShapeStyle() -> ShapeStyle`, `fillStyle: FillStyle` |
|:white_check_mark:| Slider | `contained view`, `callOnEditingChanged()` |
|:white_check_mark:| Spacer | `minLength: CGFloat?` |
|:white_check_mark:| Stepper | `contained view`, `increment()`, `decrement()`, `callOnEditingChanged()` |
|:technologist:| SubscriptionView | |
|:white_check_mark:| TabView | `contained view` |
|:white_check_mark:| Text | `string: String?`, `attributes: TextAttributes` |
|:technologist:| TextEditor | |
|:white_check_mark:| TextField | `contained view`, `callOnEditingChanged()`, `callOnCommit()` |
|:white_check_mark:| Toggle | `contained view` |
|:technologist:| ToggleStyleConfiguration.Label | |
|:white_check_mark:| TouchBar | `contained view`, `touchBarID: String` |
|:technologist:| TupleView | |
|:white_check_mark:| VSplitView | `contained view` |
|:white_check_mark:| VStack | `contained view` |
|:white_check_mark:| ZStack | `contained view` |

## Property Wrappers

| Status | Modifier |
|:---:|---|
|:technologist:| `@AppStorage` |
|:white_check_mark:| `@Binding` |
|:white_check_mark:| `@Environment` |
|:white_check_mark:| `@EnvironmentObject` |
|:technologist:| `@FetchRequest` |
|:technologist:| `@FocusedBinding` |
|:technologist:| `@FocusedValue` |
|:technologist:| `@GestureState` |
|:technologist:| `@Namespace` |
|:white_check_mark:| `@ObservedObject` |
|:technologist:| `@ScaledMetric` |
|:technologist:| `@SceneStorage` |
|:white_check_mark:| `@State` |
|:technologist:| `@StateObject` |
|:technologist:| `@UIApplicationDelegateAdaptor` |

## View Modifiers

### Sizing a View

| Status | Modifier |
|:---:|---|
|:white_check_mark:| `func frame(width: CGFloat?, height: CGFloat?, alignment: Alignment) -> some View` |
|:white_check_mark:| `func frame(minWidth: CGFloat?, idealWidth: CGFloat?, maxWidth: CGFloat?, minHeight: CGFloat?, idealHeight: CGFloat?, maxHeight: CGFloat?, alignment: Alignment) -> some View` |
|:white_check_mark:| `func fixedSize() -> some View` |
|:white_check_mark:| `func fixedSize(horizontal: Bool, vertical: Bool) -> some View` |
|:white_check_mark:| `func layoutPriority(Double) -> some View` |

### Positioning a View

| Status | Modifier |
|:---:|---|
|:white_check_mark:| `func position(CGPoint) -> some View` |
|:white_check_mark:| `func position(x: CGFloat, y: CGFloat) -> some View` |
|:white_check_mark:| `func offset(CGSize) -> some View` |
|:white_check_mark:| `func offset(x: CGFloat, y: CGFloat) -> some View` |
|:white_check_mark:| `func edgesIgnoringSafeArea(Edge.Set) -> some View` |
|:white_check_mark:| `func coordinateSpace<T>(name: T) -> some View` |

### Aligning Views

| Status | Modifier |
|:---:|---|
|:heavy_check_mark:| `func alignmentGuide(HorizontalAlignment, computeValue: (ViewDimensions) -> CGFloat) -> some View` |
|:heavy_check_mark:| `func alignmentGuide(VerticalAlignment, computeValue: (ViewDimensions) -> CGFloat) -> some View` |

### Adjusting the Padding of a View

| Status | Modifier |
|:---:|---|
|:white_check_mark:| `func padding(CGFloat) -> some View` |
|:white_check_mark:| `func padding(EdgeInsets) -> some View` |
|:white_check_mark:| `func padding(Edge.Set, CGFloat?) -> some View` |

### Layering Views

| Status | Modifier |
|:---:|---|
|:white_check_mark:| `func overlay<Overlay>(Overlay, alignment: Alignment) -> some View` |
|:white_check_mark:| `func background<Background>(Background, alignment: Alignment) -> some View` |
|:white_check_mark:| `func zIndex(Double) -> some View` |

### Masking and Clipping Views

| Status | Modifier |
|:---:|---|
|:white_check_mark:| `func clipped(antialiased: Bool) -> some View` |
|:white_check_mark:| `func clipShape<S>(S, style: FillStyle) -> some View` |
|:white_check_mark:| `func cornerRadius(CGFloat, antialiased: Bool) -> some View` |
|:white_check_mark:| `func mask<Mask>(Mask) -> some View` |

### Scaling Views

| Status | Modifier |
|:---:|---|
|:white_check_mark:| `func scaledToFill() -> some View` |
|:white_check_mark:| `func scaledToFit() -> some View` |
|:white_check_mark:| `func scaleEffect(CGFloat, anchor: UnitPoint) -> some View` |
|:white_check_mark:| `func scaleEffect(CGSize, anchor: UnitPoint) -> some View` |
|:white_check_mark:| `func scaleEffect(x: CGFloat, y: CGFloat, anchor: UnitPoint) -> some View` |
|:white_check_mark:| `func aspectRatio(CGFloat?, contentMode: ContentMode) -> some View` |
|:white_check_mark:| `func aspectRatio(CGSize, contentMode: ContentMode) -> some View` |
|:white_check_mark:| `func imageScale(Image.Scale) -> some View` |

### Rotating and Transforming Views

| Status | Modifier |
|:---:|---|
|:white_check_mark:| `func rotationEffect(Angle, anchor: UnitPoint) -> some View` |
|:white_check_mark:| `func rotation3DEffect(Angle, axis: (x: CGFloat, y: CGFloat, z: CGFloat), anchor: UnitPoint, anchorZ: CGFloat, perspective: CGFloat) -> some View` |
|:white_check_mark:| `func projectionEffect(ProjectionTransform) -> some View` |
|:white_check_mark:| `func transformEffect(CGAffineTransform) -> some View` |

### Applying Graphical Effects to a View

| Status | Modifier |
|:---:|---|
|:white_check_mark:| `func blur(radius: CGFloat, opaque: Bool) -> some View` |
|:white_check_mark:| `func opacity(Double) -> some View` |
|:white_check_mark:| `func brightness(Double) -> some View` |
|:white_check_mark:| `func contrast(Double) -> some View` |
|:white_check_mark:| `func colorInvert() -> some View` |
|:white_check_mark:| `func colorMultiply(Color) -> some View` |
|:white_check_mark:| `func saturation(Double) -> some View` |
|:white_check_mark:| `func grayscale(Double) -> some View` |
|:white_check_mark:| `func hueRotation(Angle) -> some View` |
|:white_check_mark:| `func luminanceToAlpha() -> some View` |
|:white_check_mark:| `func shadow(color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) -> some View` |

### Compositing Views

| Status | Modifier |
|:---:|---|
|:white_check_mark:| `func blendMode(BlendMode) -> some View` |
|:heavy_check_mark:| `func compositingGroup() -> some View` |
|:heavy_check_mark:| `func drawingGroup(opaque: Bool, colorMode: ColorRenderingMode) -> some View` |

### Adding Animations to a View

| Status | Modifier |
|:---:|---|
|:heavy_check_mark:| `func animation(Animation?) -> some View` |
|:heavy_check_mark:| `func animation<V>(Animation?, value: V) -> some View` |
|:white_check_mark:| `func transition(AnyTransition) -> some View` |
|:technologist:| `func matchedGeometryEffect<ID>(id: ID, in: Namespace.ID, properties: MatchedGeometryProperties, anchor: UnitPoint, isSource: Bool) -> some View` |

### Text modifiers

| Status | Modifier |
|:---:|---|
|:white_check_mark:| `func foregroundColor(_ color: Color?) -> Text` |
|:white_check_mark:| `func font(_ font: Font?) -> Text` |
|:white_check_mark:| `func fontWeight(_ weight: Font.Weight?) -> Text` |
|:white_check_mark:| `func bold() -> Text` |
|:white_check_mark:| `func italic() -> Text` |
|:white_check_mark:| `func strikethrough(_ active: Bool, color: Color?) -> Text` |
|:white_check_mark:| `func underline(_ active: Bool, color: Color?) -> Text` |
|:white_check_mark:| `func kerning(_ kerning: CGFloat) -> Text` |
|:white_check_mark:| `func tracking(_ tracking: CGFloat) -> Text` |
|:white_check_mark:| `func baselineOffset(_ baselineOffset: CGFloat) -> Text` |

### Handling View Taps and Gestures

| Status | Modifier |
|:---:|---|
|:white_check_mark:| `func onTapGesture(count: Int, perform: () -> Void) -> some View` |
|:white_check_mark:| `func onLongPressGesture(minimumDuration: Double, maximumDistance: CGFloat, pressing: ((Bool) -> Void)?, perform: () -> Void) -> some View` |
|:heavy_check_mark:| `func gesture<T>(T, including: GestureMask) -> some View` |
|:heavy_check_mark:| `func highPriorityGesture<T>(T, including: GestureMask) -> some View` |
|:heavy_check_mark:| `func simultaneousGesture<T>(T, including: GestureMask) -> some View` |
|:white_check_mark:| `func transaction((inout Transaction) -> Void) -> some View` |

### Handling Application Life Cycle Events

| Status | Modifier |
|:---:|---|
|:technologist:| `func userActivity<P>(String, element: P?, (P, NSUserActivity) -> ()) -> some View` |
|:technologist:| `func userActivity(String, isActive: Bool, (NSUserActivity) -> ()) -> some View` |
|:technologist:| `func onContinueUserActivity(String, perform: (NSUserActivity) -> ()) -> some View` |
|:technologist:| `func onOpenURL(perform: (URL) -> ()) -> some View` |
|:technologist:| `func widgetURL(URL?) -> some View` |
|:technologist:| `func handlesExternalEvents(preferring: Set<String>, allowing: Set<String>) -> some View` |

### Handling View Events

| Status | Modifier |
|:---:|---|
|:white_check_mark:| `func onAppear(perform: (() -> Void)?) -> some View` |
|:white_check_mark:| `func onDisappear(perform: (() -> Void)?) -> some View` |
|:white_check_mark:| `func onCutCommand(perform: (() -> [NSItemProvider])?) -> some View` |
|:white_check_mark:| `func onCopyCommand(perform: (() -> [NSItemProvider])?) -> some View` |
|:heavy_check_mark:| `func onPasteCommand(of: [String], perform: ([NSItemProvider]) -> Void) -> some View` |
|:technologist:| `func onPasteCommand(of: [UTType], perform: ([NSItemProvider]) -> Void) -> some View` |
|:technologist:| `func onPasteCommand<Payload>(of: [UTType], validator: ([NSItemProvider]) -> Payload?, perform: (Payload) -> Void) -> some View` |
|:heavy_check_mark:| `func onPasteCommand<Payload>(of: [String], validator: ([NSItemProvider]) -> Payload?, perform: (Payload) -> Void) -> some View` |
|:white_check_mark:| `func onDeleteCommand(perform: (() -> Void)?) -> some View` |
|:white_check_mark:| `func onMoveCommand(perform: ((MoveCommandDirection) -> Void)?) -> some View` |
|:white_check_mark:| `func onExitCommand(perform: (() -> Void)?) -> some View` |
|:heavy_check_mark:| `func onPlayPauseCommand(perform: (() -> Void)?) -> some View` |
|:white_check_mark:| `func onCommand(Selector, perform: (() -> Void)?) -> some View` |
|:heavy_check_mark:| `func deleteDisabled(Bool) -> some View` |
|:heavy_check_mark:| `func moveDisabled(Bool) -> some View` |

### Handling Publisher Events

| Status | Modifier |
|:---:|---|
|:heavy_check_mark:| `func onReceive<P>(P, perform: (P.Output) -> Void) -> some View` |
|:technologist:| `func onChange<V>(of: V, perform: (V) -> Void) -> some View` |

### Handling Keyboard Shortcuts

| Status | Modifier |
|:---:|---|
|:technologist:| `func keyboardShortcut(KeyboardShortcut) -> some View` |
|:technologist:| `func keyboardShortcut(KeyEquivalent, modifiers: EventModifiers) -> some View` |

### Handling View Hover and Focus

| Status | Modifier |
|:---:|---|
|:heavy_check_mark:| `func onHover(perform: (Bool) -> Void) -> some View` |
|:white_check_mark:| `func focusable(Bool, onFocusChange: (Bool) -> Void) -> some View` |
|:technologist:| `func focusedValue<Value>(WritableKeyPath<FocusedValues, Value?>, Value) -> some View` |
|:technologist:| `func prefersDefaultFocus(Bool, in: Namespace.ID) -> some View` |
|:technologist:| `func focusScope(Namespace.ID) -> some View` |
|:technologist:| `func hoverEffect(HoverEffect) -> some View` |

### Supporting Drag and Drop in Views

| Status | Modifier |
|:---:|---|
|:heavy_check_mark:| `func onDrag(() -> NSItemProvider) -> some View` |
|:technologist:| `func onDrop(of: [UTType], delegate: DropDelegate) -> some View` |
|:technologist:| `func onDrop(of: [UTType], isTargeted: Binding<Bool>?, perform: ([NSItemProvider]) -> Bool) -> some View` |
|:technologist:| `func onDrop(of: [UTType], isTargeted: Binding<Bool>?, perform: ([NSItemProvider], CGPoint) -> Bool) -> some View` |
|:heavy_check_mark:| `func onDrop(of: [String], delegate: DropDelegate) -> some View` |
|:heavy_check_mark:| `func onDrop(of: [String], isTargeted: Binding<Bool>?, perform: ([NSItemProvider], CGPoint) -> Bool) -> some View` |
|:heavy_check_mark:| `func onDrop(of: [String], isTargeted: Binding<Bool>?, perform: ([NSItemProvider]) -> Bool) -> some View` |
|:heavy_check_mark:| `func itemProvider(Optional<() -> NSItemProvider?>) -> some View` |

### Configuring a View for Hit Testing

| Status | Modifier |
|:---:|---|
|:white_check_mark:| `func allowsHitTesting(Bool) -> some View` |
|:white_check_mark:| `func contentShape<S>(S, eoFill: Bool) -> some View` |

### Presenting Action Sheets

| Status | Modifier |
|:---:|---|
|:heavy_check_mark:| `func actionSheet(isPresented: Binding<Bool>, content: () -> ActionSheet) -> some View` |
|:heavy_check_mark:| `func actionSheet<T>(item: Binding<T?>, content: (T) -> ActionSheet) -> some View` |

### Presenting Sheets

| Status | Modifier |
|:---:|---|
|:heavy_check_mark:| `func sheet<Content>(isPresented: Binding<Bool>, onDismiss: (() -> Void)?, content: () -> Content) -> some View` |
|:heavy_check_mark:| `func sheet<Item, Content>(item: Binding<Item?>, onDismiss: (() -> Void)?, content: (Item) -> Content) -> some View` |
|:technologist:| `func fullScreenCover<Content>(isPresented: Binding<Bool>, onDismiss: (() -> Void)?, content: () -> Content) -> some View` |
|:technologist:| `func fullScreenCover<Item, Content>(item: Binding<Item?>, onDismiss: (() -> Void)?, content: (Item) -> Content) -> some View` |

### Presenting Alerts

| Status | Modifier |
|:---:|---|
|:heavy_check_mark:| `func alert(isPresented: Binding<Bool>, content: () -> Alert) -> some View` |
|:heavy_check_mark:| `func alert<Item>(item: Binding<Item?>, content: (Item) -> Alert) -> some View` |

### Presenting Popovers

| Status | Modifier |
|:---:|---|
|:heavy_check_mark:| `func popover<Content>(isPresented: Binding<Bool>, attachmentAnchor: PopoverAttachmentAnchor, arrowEdge: Edge, content: () -> Content) -> some View` |
|:heavy_check_mark:| `func popover<Item, Content>(item: Binding<Item?>, attachmentAnchor: PopoverAttachmentAnchor, arrowEdge: Edge, content: (Item) -> Content) -> some View` |

### Presenting an App Store Overlay

>>>

### Presenting File Management Interfaces

| Status | Modifier |
|:---:|---|
|:technologist:| `func fileExporter<D>(isPresented: Binding<Bool>, document: D?, contentType: UTType, defaultFilename: String?, onCompletion: (Result<URL, Error>) -> Void) -> some View` |
|:technologist:| `func fileExporter<D>(isPresented: Binding<Bool>, document: D?, contentType: UTType, defaultFilename: String?, onCompletion: (Result<URL, Error>) -> Void) -> some View` |
|:technologist:| `func fileExporter<C>(isPresented: Binding<Bool>, documents: C, contentType: UTType, onCompletion: (Result<[URL], Error>) -> Void) -> some View` |
|:technologist:| `func fileExporter<C>(isPresented: Binding<Bool>, documents: C, contentType: UTType, onCompletion: (Result<[URL], Error>) -> Void) -> some View` |
|:technologist:| `func fileImporter(isPresented: Binding<Bool>, allowedContentTypes: [UTType], allowsMultipleSelection: Bool, onCompletion: (Result<[URL], Error>) -> Void) -> some View` |
|:technologist:| `func fileImporter(isPresented: Binding<Bool>, allowedContentTypes: [UTType], onCompletion: (Result<URL, Error>) -> Void) -> some View` |
|:technologist:| `func fileMover(isPresented: Binding<Bool>, file: URL?, onCompletion: (Result<URL, Error>) -> Void) -> some View` |
|:technologist:| `func fileMover<C>(isPresented: Binding<Bool>, files: C, onCompletion: (Result<[URL], Error>) -> Void) -> some View` |

### Choosing the Default Storage

| Status | Modifier |
|:---:|---|
|:technologist:| `func defaultAppStorage(UserDefaults) -> some View` |

### Setting View Preferences

| Status | Modifier |
|:---:|---|
|:heavy_check_mark:| `func preference<K>(key: K.Type, value: K.Value) -> some View` |
|:heavy_check_mark:| `func transformPreference<K>(K.Type, (inout K.Value) -> Void) -> some View` |
|:heavy_check_mark:| `func anchorPreference<A, K>(key: K.Type, value: Anchor<A>.Source, transform: (Anchor<A>) -> K.Value) -> some View` |
|:heavy_check_mark:| `func transformAnchorPreference<A, K>(key: K.Type, value: Anchor<A>.Source, transform: (inout K.Value, Anchor<A>) -> Void) -> some View` |

### Responding to View Preferences

| Status | Modifier |
|:---:|---|
|:heavy_check_mark:| `func onPreferenceChange<K>(K.Type, perform: (K.Value) -> Void) -> some View` |
|:x:| `func backgroundPreferenceValue<Key, T>(Key.Type, (Key.Value) -> T) -> some View` |
|:x:| `func overlayPreferenceValue<Key, T>(Key.Type, (Key.Value) -> T) -> some View` |

### Setting the Environment Values of a View

| Status | Modifier |
|:---:|---|
|:heavy_check_mark:| `func environment<V>(WritableKeyPath<EnvironmentValues, V>, V) -> some View` |
|:heavy_check_mark:| `func environmentObject<B>(B) -> some View` |
|:heavy_check_mark:| `func transformEnvironment<V>(WritableKeyPath<EnvironmentValues, V>, transform: (inout V) -> Void) -> some View` |

### Setting the Border of a View

| Status | Modifier |
|:---:|---|
|:white_check_mark:| `func border<S>(S, width: CGFloat) -> some View` |

### Setting View Colors

| Status | Modifier |
|:---:|---|
|:white_check_mark:| `func foregroundColor(Color?) -> some View` |
|:white_check_mark:| `func accentColor(Color?) -> some View` |

### Adopting View Color Schemes

| Status | Modifier |
|:---:|---|
|:white_check_mark:| `func colorScheme(ColorScheme) -> some View` |
|:white_check_mark:| `func preferredColorScheme(ColorScheme?) -> some View` |

### Adjusting Text in a View

| Status | Modifier |
|:---:|---|
|:white_check_mark:| `func keyboardType(UIKeyboardType) -> some View` |
|:white_check_mark:| `func font(Font?) -> some View` |
|:heavy_check_mark:| `func lineLimit(Int?) -> some View` |
|:heavy_check_mark:| `func lineSpacing(CGFloat) -> some View` |
|:heavy_check_mark:| `func multilineTextAlignment(TextAlignment) -> some View` |
|:heavy_check_mark:| `func minimumScaleFactor(CGFloat) -> some View` |
|:heavy_check_mark:| `func truncationMode(Text.TruncationMode) -> some View` |
|:heavy_check_mark:| `func allowsTightening(Bool) -> some View` |
|:white_check_mark:| `func textContentType(UITextContentType?) -> some View` |
|:technologist:| `func textContentType(NSTextContentType?) -> some View` |
|:technologist:| `func textCase(Text.Case?) -> some View` |
|:white_check_mark:| `func flipsForRightToLeftLayoutDirection(Bool) -> some View` |
|:white_check_mark:| `func autocapitalization(UITextAutocapitalizationType) -> some View` |
|:white_check_mark:| `func disableAutocorrection(Bool?) -> some View` |

### Redacting Content

| Status | Modifier |
|:---:|---|
|:technologist:| `func redacted(reason: RedactionReasons) -> some View` |
|:technologist:| `func unredacted() -> some View` |

### Configuring Control Attributes

| Status | Modifier |
|:---:|---|
|:heavy_check_mark:| `func labelsHidden() -> some View` |
|:heavy_check_mark:| `func horizontalRadioGroupLayout() -> some View` |
|:heavy_check_mark:| `func controlSize(ControlSize) -> some View` |

### Styling Specific View Types

| Status | Modifier |
|:---:|---|
|:technologist:| `func labelStyle<S>(S) -> some View` |
|:white_check_mark:| `func buttonStyle<S>(S) -> some View` |
|:white_check_mark:| `func menuButtonStyle<S>(S) -> some View` |
|:technologist:| `func menuStyle<S>(S) -> some View` |
|:white_check_mark:| `func pickerStyle<S>(S) -> some View` |
|:white_check_mark:| `func datePickerStyle<S>(S) -> some View` |
|:white_check_mark:| `func textFieldStyle<S>(S) -> some View` |
|:white_check_mark:| `func toggleStyle<S>(S) -> some View` |
|:technologist:| `func indexViewStyle<S>(S) -> some View` |
|:white_check_mark:| `func listStyle<S>(S) -> some View` |
|:technologist:| `func groupBoxStyle<S>(S) -> some View` |
|:white_check_mark:| `func navigationViewStyle<S>(S) -> some View` |
|:technologist:| `func progressViewStyle<S>(S) -> some View` |
|:technologist:| `func gaugeStyle<S>(S) -> some View` |
|:technologist:| `func presentedWindowStyle<S>(S) -> some View` |
|:technologist:| `func presentedWindowToolbarStyle<S>(S) -> some View` |

### Configuring a List View

| Status | Modifier |
|:---:|---|
|:white_check_mark:| `func listRowInsets(EdgeInsets?) -> some View` |
|:white_check_mark:| `func listRowBackground<V>(V?) -> some View` |
|:white_check_mark:| `func tag<V>(V) -> some View` |

### Tinting a List Item

| Status | Modifier |
|:---:|---|
|:technologist:| `func listItemTint(ListItemTint?) -> some View` |
|:technologist:| `func listItemTint(Color?) -> some View` |

### Configuring the Navigation Title

| Status | Modifier |
|:---:|---|
|:technologist:| `func navigationTitle(LocalizedStringKey) -> some View` |
|:technologist:| `func navigationTitle(Text) -> some View` |
|:technologist:| `func navigationTitle<S>(S) -> some View` |
|:technologist:| `func navigationTitle<V>(() -> V) -> some View` |
|:technologist:| `func navigationSubtitle<S>(S) -> some View` |
|:technologist:| `func navigationSubtitle(Text) -> some View` |
|:technologist:| `func navigationSubtitle(LocalizedStringKey) -> some View` |

### Configuring Navigation and Status Bar Views

| Status | Modifier |
|:---:|---|
|:heavy_check_mark:| `func navigationBarTitle(Text) -> some View` |
|:heavy_check_mark:| `func navigationBarTitle(Text, displayMode: NavigationBarItem.TitleDisplayMode) -> some View` |
|:heavy_check_mark:| `func navigationBarTitle(LocalizedStringKey) -> some View` |
|:heavy_check_mark:| `func navigationBarTitle<S>(S) -> some View` |
|:heavy_check_mark:| `func navigationBarTitle(LocalizedStringKey, displayMode: NavigationBarItem.TitleDisplayMode) -> some View` |
|:technologist:| `func navigationBarTitleDisplayMode(NavigationBarItem.TitleDisplayMode) -> some View` |
|:heavy_check_mark:| `func navigationBarHidden(Bool) -> some View` |
|:heavy_check_mark:| `func statusBar(hidden: Bool) -> some View` |

### Configuring Navigation and Tab Bar Item Views

| Status | Modifier |
|:---:|---|
|:heavy_check_mark:| `func navigationBarBackButtonHidden(Bool) -> some View` |
|:heavy_check_mark:| `func navigationBarItems<L>(leading: L) -> some View` |
|:heavy_check_mark:| `func navigationBarItems<L, T>(leading: L, trailing: T) -> some View` |
|:heavy_check_mark:| `func navigationBarItems<T>(trailing: T) -> some View` |
|:white_check_mark:| `func tabItem<V>(() -> V) -> some View` |
|:technologist:| `func tabViewStyle<S>(S) -> some View` |

### Configuring Toolbar Items

| Status | Modifier |
|:---:|---|
|:technologist:| `func toolbar<Content>(content: () -> Content) -> some View` |
|:technologist:| `func toolbar<Content>(content: () -> Content) -> some View` |
|:technologist:| `func toolbar<Content>(id: String, content: () -> Content) -> some View` |

### Configuring Context Menu Views

| Status | Modifier |
|:---:|---|
|:heavy_check_mark:| `func contextMenu<MenuItems>(ContextMenu<MenuItems>?) -> some View` |
|:heavy_check_mark:| `func contextMenu<MenuItems>(menuItems: () -> MenuItems) -> some View` |

### Configuring Touch Bar Views

| Status | Modifier |
|:---:|---|
|:white_check_mark:| `func touchBar<Content>(content: () -> Content) -> some View` |
|:white_check_mark:| `func touchBar<Content>(TouchBar<Content>) -> some View` |
|:white_check_mark:| `func touchBarItemPrincipal(Bool) -> some View` |
|:white_check_mark:| `func touchBarCustomizationLabel(Text) -> some View` |
|:white_check_mark:| `func touchBarItemPresence(TouchBarItemPresence) -> some View` |

### Configuring Scroll Views

>>>

### Hiding and Disabling Views

| Status | Modifier |
|:---:|---|
|:white_check_mark:| `func hidden() -> some View` |
|:heavy_check_mark:| `func disabled(Bool) -> some View` |

### Customizing Accessibility Labels of a View

| Status | Modifier |
|:---:|---|
|:technologist:| `func accessibilityLabel<S>(S) -> ModifiedContent<Self, AccessibilityAttachmentModifier>` |
|:technologist:| `func accessibilityLabel(Text) -> ModifiedContent<Self, AccessibilityAttachmentModifier>` |
|:technologist:| `func accessibilityLabel(LocalizedStringKey) -> ModifiedContent<Self, AccessibilityAttachmentModifier>` |
|:technologist:| `func accessibilityValue<S>(S) -> ModifiedContent<Self, AccessibilityAttachmentModifier>` |
|:technologist:| `func accessibilityValue(LocalizedStringKey) -> ModifiedContent<Self, AccessibilityAttachmentModifier>` |
|:technologist:| `func accessibilityValue(Text) -> ModifiedContent<Self, AccessibilityAttachmentModifier>` |
|:technologist:| `func accessibilityHidden(Bool) -> ModifiedContent<Self, AccessibilityAttachmentModifier>` |
|:technologist:| `func accessibilityIdentifier(String) -> ModifiedContent<Self, AccessibilityAttachmentModifier>` |

### Customizing Accessibility Interactions of a View

| Status | Modifier |
|:---:|---|
|:technologist:| `func accessibilityHint(LocalizedStringKey) -> ModifiedContent<Self, AccessibilityAttachmentModifier>` |
|:technologist:| `func accessibilityHint(Text) -> ModifiedContent<Self, AccessibilityAttachmentModifier>` |
|:technologist:| `func accessibilityHint<S>(S) -> ModifiedContent<Self, AccessibilityAttachmentModifier>` |
|:technologist:| `func accessibilityActivationPoint(CGPoint) -> ModifiedContent<Self, AccessibilityAttachmentModifier>` |
|:technologist:| `func accessibilityActivationPoint(UnitPoint) -> ModifiedContent<Self, AccessibilityAttachmentModifier>` |
|:white_check_mark:| `func accessibilityAction(AccessibilityActionKind, () -> Void) -> ModifiedContent<Self, AccessibilityAttachmentModifier>` |
|:heavy_check_mark:| `func accessibilityAction(named: Text, () -> Void) -> ModifiedContent<Self, AccessibilityAttachmentModifier>` |
|:technologist:| `func accessibilityAction<S>(named: S, () -> Void) -> ModifiedContent<Self, AccessibilityAttachmentModifier>` |
|:technologist:| `func accessibilityAction(named: LocalizedStringKey, () -> Void) -> ModifiedContent<Self, AccessibilityAttachmentModifier>` |
|:white_check_mark:| `func accessibilityAdjustableAction((AccessibilityAdjustmentDirection) -> Void) -> ModifiedContent<Self, AccessibilityAttachmentModifier>` |
|:white_check_mark:| `func accessibilityScrollAction((Edge) -> Void) -> ModifiedContent<Self, AccessibilityAttachmentModifier>` |
|:technologist:| `func accessibilityIgnoresInvertColors(Bool) -> some View` |
|:technologist:| `func accessibilityLabeledPair<ID>(role: AccessibilityLabeledPairRole, id: ID, in: Namespace.ID) -> some View` |

### Customizing Accessibility Navigation of a View

| Status | Modifier |
|:---:|---|
|:heavy_check_mark:| `func accessibilityElement(children: AccessibilityChildBehavior) -> some View` |
|:technologist:| `func accessibilityInputLabels([LocalizedStringKey]) -> ModifiedContent<Self, AccessibilityAttachmentModifier>` |
|:technologist:| `func accessibilityInputLabels<S>([S]) -> ModifiedContent<Self, AccessibilityAttachmentModifier>` |
|:technologist:| `func accessibilityInputLabels([Text]) -> ModifiedContent<Self, AccessibilityAttachmentModifier>` |
|:technologist:| `func accessibilityAddTraits(AccessibilityTraits) -> ModifiedContent<Self, AccessibilityAttachmentModifier>` |
|:technologist:| `func accessibilityRemoveTraits(AccessibilityTraits) -> ModifiedContent<Self, AccessibilityAttachmentModifier>` |
|:technologist:| `func accessibilitySortPriority(Double) -> ModifiedContent<Self, AccessibilityAttachmentModifier>` |` |
|:technologist:| `func accessibilityLinkedGroup<ID>(id: ID, in: Namespace.ID) -> some View` |

### Customizing the Help Text of a View

| Status | Modifier |
|:---:|---|
|:technologist:| `func help(LocalizedStringKey) -> some View` |
|:technologist:| `func help<S>(S) -> some View` |
|:technologist:| `func help(Text) -> some View` |

### Deprecated Accessibility Modifiers

| Status | Modifier |
|:---:|---|
|:white_check_mark:| `func accessibility(label: Text) -> ModifiedContent<Self, AccessibilityAttachmentModifier>` |
|:white_check_mark:| `func accessibility(value: Text) -> ModifiedContent<Self, AccessibilityAttachmentModifier>` |
|:white_check_mark:| `func accessibility(hidden: Bool) -> ModifiedContent<Self, AccessibilityAttachmentModifier>` |
|:white_check_mark:| `func accessibility(identifier: String) -> ModifiedContent<Self, AccessibilityAttachmentModifier>` |
|:white_check_mark:| `func accessibility(selectionIdentifier: AnyHashable) -> ModifiedContent<Self, AccessibilityAttachmentModifier>` |
|:white_check_mark:| `func accessibility(hint: Text) -> ModifiedContent<Self, AccessibilityAttachmentModifier>` |
|:white_check_mark:| `func accessibility(activationPoint: UnitPoint) -> ModifiedContent<Self, AccessibilityAttachmentModifier>` |
|:white_check_mark:| `func accessibility(activationPoint: CGPoint) -> ModifiedContent<Self, AccessibilityAttachmentModifier>` |
|:technologist:| `func accessibility(inputLabels: [Text]) -> ModifiedContent<Self, AccessibilityAttachmentModifier>` |
|:heavy_check_mark:| `func accessibility(addTraits: AccessibilityTraits) -> ModifiedContent<Self, AccessibilityAttachmentModifier>` |
|:heavy_check_mark:| `func accessibility(removeTraits: AccessibilityTraits) -> ModifiedContent<Self, AccessibilityAttachmentModifier>` |
|:white_check_mark:| `func accessibility(sortPriority: Double) -> ModifiedContent<Self, AccessibilityAttachmentModifier>` |

### Configuring View Previews

| Status | Modifier |
|:---:|---|
|:white_check_mark:| `func previewDevice(PreviewDevice?) -> some View` |
|:white_check_mark:| `func previewDisplayName(String?) -> some View` |
|:white_check_mark:| `func previewLayout(PreviewLayout) -> some View` |
|:technologist:| `func previewContext<C>(C) -> some View` |

### Inspecting Views

| Status | Modifier |
|:---:|---|
|:white_check_mark:| `func id<ID>(ID) -> some View` |
|:white_check_mark:| `func equatable() -> EquatableView<Self>` |

### Implementing View Modifiers

| Status | Modifier |
|:---:|---|
|:heavy_check_mark:| `func modifier<T>(T) -> ModifiedContent<Self, T>` |
