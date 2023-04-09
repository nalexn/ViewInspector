# ViewInspector readiness list

This document reflects the current status of the [ViewInspector](https://github.com/nalexn/ViewInspector) framework: which `Views` and `Modifiers` are available for inspection.

**Please open a PR if any `View` or `Modifier` is not listed!**

### Denotations

| Status | Meaning |
|:---:|---|
|:white_check_mark:| Full inspection support with access to the underlying values or callbacks |
|:technologist:| Pending development |

## View Types

| Status | View | Inspectable Attributes |
|:---:|---|---|
|:white_check_mark:| ActionSheet | `title view`, `message view`, `button(_ index: Int)`, `dismiss()` |
|:white_check_mark:| Alert | `title view`, `message view`, `actions view`, `primaryButton`, `secondaryButton`, `dismiss()` |
|:white_check_mark:| AngularGradient | `gradient: Gradient`, `center: UnitPoint`, `startAngle: Angle`, `endAngle: Angle` |
|:white_check_mark:| AnyView | `contained view` |
|:technologist:| ArtworkImage | |
|:white_check_mark:| AsyncImage | `contentView(AsyncImagePhase)`, `url: URL`, `scale: CGFloat`, `transaction: Transaction` |
|:white_check_mark:| Button | `label view`, `role: ButtonRole?`, `tap()` |
|:white_check_mark:| ButtonStyleConfiguration.Label | |
|:technologist:| CameraView | |
|:white_check_mark:| Canvas | `symbols view`, `colorMode: ColorRenderingMode`, `opaque: Bool`, `rendersAsynchronously: Bool` |
|:white_check_mark:| Color | `value: Color`, `rgba: (Float, Float, Float, Float)`, `name: String` |
|:white_check_mark:| ColorPicker | `label view`, `select(color: Color)` |
|:white_check_mark:| ControlGroup | |
|:white_check_mark:| ConditionalContent | `contained view` |
|:white_check_mark:| ConfirmationDialog | `title view`, `message view`, `actions view`, `titleVisibility: Visibility`, `dismiss()` |
|:white_check_mark:| Custom View | `actualView: CustomView`, `viewBuilder container` |
|:white_check_mark:| Custom ViewModifier | |
|:white_check_mark:| Custom ViewModifier.Content | |
|:white_check_mark:| UIViewRepresentable | `uiView: UIView` |
|:white_check_mark:| UIViewControllerRepresentable | `viewController: UIViewController` |
|:white_check_mark:| DatePicker | `label view`, `select(date: Date)` |
|:white_check_mark:| DisclosureGroup | `contained view`, `label view`, `isExpanded: Bool`, `expand()`, `collapse()` |
|:white_check_mark:| Divider | |
|:white_check_mark:| EditButton | `editMode: Binding<EditMode>?` |
|:white_check_mark:| EllipticalGradient | `gradient: Gradient`, `center: UnitPoint`, `startRadiusFraction: CGFloat`, `endRadiusFraction: CGFloat` |
|:white_check_mark:| EmptyView | |
|:white_check_mark:| EquatableView | `contained view` |
|:white_check_mark:| Font (*) | `size: CGFloat`, `isFixedSize: Bool`, `name: String`, `weight: Font.Weight`, `design: Font.Design`, `style: Font.TextStyle` |
|:white_check_mark:| ForEach | `contained view`, `callOnDelete`, `callOnMove`, `callOnInsert` |
|:white_check_mark:| Form | `contained view` |
|:technologist:| Gauge | |
|:white_check_mark:| FullScreenCover | `dismiss()` |
|:white_check_mark:| GeometryReader | `contained view` |
|:white_check_mark:| Group | `contained view` |
|:white_check_mark:| GroupBox | `contained view`, `label view` |
|:white_check_mark:| HSplitView | `contained view` |
|:white_check_mark:| HStack | `contained view`, `alignment: VerticalAlignment`, `spacing: CGFloat?` |
|:white_check_mark:| Image | `label view`, `actualImage: Image` |
|:white_check_mark:| Image (*) | `rootImage: Image`, `name: String?`, `(ui,ns,cg)Image: (UI,NS,CG)Image`, `orientation: Image.Orientation`, `scale: CGFloat` |
|:white_check_mark:| Label | `title view`, `icon view` |
|:white_check_mark:| LabelStyleConfiguration.Icon | |
|:white_check_mark:| LabelStyleConfiguration.Title | |
|:white_check_mark:| LazyHGrid | `contained view`, `alignment: VerticalAlignment`, `spacing: CGFloat?`, `pinnedViews: PinnedScrollableViews`, `rows: [GridItem]` |
|:white_check_mark:| LazyHStack | `contained view`, `alignment: VerticalAlignment`, `spacing: CGFloat?`, `pinnedViews: PinnedScrollableViews` |
|:white_check_mark:| LazyVGrid | `contained view`, `alignment: HorizontalAlignment`, `spacing: CGFloat?`, `pinnedViews: PinnedScrollableViews`, `columns: [GridItem]` |
|:white_check_mark:| LazyVStack | `contained view`, `alignment: HorizontalAlignment`, `spacing: CGFloat?`, `pinnedViews: PinnedScrollableViews` |
|:white_check_mark:| LinearGradient | `gradient: Gradient`, `startPoint: UnitPoint`, `endPoint: UnitPoint` |
|:white_check_mark:| Link | `label view`, `url: URL` |
|:white_check_mark:| List | `contained view` |
|:white_check_mark:| LocationButton | `title: LocationButton.Title`, `tap()` |
|:white_check_mark:| Map | `(set)coordinateRegion: MKCoordinateRegion`, `(set)userTrackingMode: MapUserTrackingMode`, `(set)mapRect: MKMapRect`, `interactionModes: MapInteractionModes`, `showsUserLocation: Bool` |
|:white_check_mark:| MapAnnotation | `coordinate: CLLocationCoordinate2D`, `viewType: MapAnnotation.Type`, (*)`anchorPoint: CGPoint`, (*)`tintColor: Color?`, (*)`contained view` |
|:white_check_mark:| Menu | `contained view`, `label view`, `primaryAction` |
|:white_check_mark:| MenuButton | `contained view`, `label view` |
|:white_check_mark:| MenuStyleConfiguration.Content | |
|:white_check_mark:| MenuStyleConfiguration.Label | |
|:white_check_mark:| ModifiedContent | `contained view` |
|:white_check_mark:| NavigationLink | `contained view`, `label view`, `isActive: Bool`, `activate()`, `deactivate()` |
|:white_check_mark:| NavigationSplitView | `contained view`, `sidebar view`, `detail view` |
|:white_check_mark:| NavigationStack | `contained view` |
|:white_check_mark:| NavigationView | `contained view` |
|:technologist:| NowPlayingView | |
|:white_check_mark:| Optional | `contained view` |
|:white_check_mark:| OutlineGroup | `leaf view`, `source data` |
|:white_check_mark:| PasteButton | `supportedTypes: [String]`|
|:white_check_mark:| Picker | `contained view`, `label view`, `select(value: Hashable)` |
|:white_check_mark:| Popover | `contained view`, `attachmentAnchor: PopoverAttachmentAnchor`, `arrowEdge: Edge`, `dismiss()` |
|:white_check_mark:| PrimitiveButtonStyleConfiguration.Label | |
|:white_check_mark:| ProgressView | `label view`, `currentValueLabel view`, `fractionCompleted: Double?`, `progress: Progress` |
|:white_check_mark:| ProgressViewStyleConfiguration.CurrentValueLabel | |
|:white_check_mark:| ProgressViewStyleConfiguration.Label | |
|:white_check_mark:| RadialGradient | `gradient: Gradient`, `center: UnitPoint`, `startRadius: CGFloat`, `endRadius: CGFloat` |
|:white_check_mark:| SafeAreaInset | `regions: SafeAreaRegions`, `spacing: CGFloat?`, `edge: Edge` |
|:technologist:| SceneView | |
|:white_check_mark:| ScrollView | `contained view`, `axes: Axis.Set`, `showsIndicators: Bool` |
|:white_check_mark:| ScrollViewReader | `contained view` |
|:white_check_mark:| Section | `contained view`, `header view`, `footer view` |
|:white_check_mark:| SecureField | `label view`, `callOnCommit()`, `input: String`, `setInput(_: String)` |
|:white_check_mark:| Shape | `func path(in rect: CGRect) -> Path`, `inset: CGFloat`, `offset: CGSize`, `scale: (x: CGFloat, y: CGFloat, anchor: UnitPoint)`, `rotation: (angle: Angle, anchor: UnitPoint)`, `transform: CGAffineTransform`, `size: CGSize`, `strokeStyle: StrokeStyle`, `trim: (from: CGFloat, to: CGFloat)`, `fillShapeStyle() -> ShapeStyle`, `fillStyle: FillStyle` |
|:white_check_mark:| Sheet | `dismiss()` |
|:white_check_mark:| SignInWithAppleButton | `labelType: SignInWithAppleButton.Label`, `tap(_: SignInOutcome)` |
|:white_check_mark:| Slider | `label view`, `callOnEditingChanged()`, `value: Double`, `setValue(_: Double)` |
|:white_check_mark:| Spacer | `minLength: CGFloat?` |
|:technologist:| SpriteView | |
|:white_check_mark:| Stepper | `label view`, `increment()`, `decrement()`, `callOnEditingChanged()` |
|:white_check_mark:| SubscriptionView | |
|:white_check_mark:| TabView | `contained view` |
|:technologist:| Table | |
|:white_check_mark:| Text | `string(locale: Locale) -> String`, `attributes: TextAttributes`, `attributedString: AttributedString`, `images: [Image]` |
|:white_check_mark:| TextEditor | `input: String`, `setInput(_: String)` |
|:white_check_mark:| TextField | `label view`, `callOnEditingChanged()`, `callOnCommit()`, `input: String`, `setInput(_: String)` |
|:white_check_mark:| TimelineView | `contentView(Context)` |
|:white_check_mark:| Toggle | `label view`, `tap()`, `isOn: Bool` |
|:white_check_mark:| ToggleStyleConfiguration.Label | |
|:white_check_mark:| ToolbarItem | |
|:white_check_mark:| TouchBar | `contained view`, `touchBarID: String` |
|:white_check_mark:| TupleView | |
|:white_check_mark:| VSplitView | `contained view` |
|:white_check_mark:| VStack | `contained view`, `alignment: VerticalAlignment`, `spacing: CGFloat?` |
|:white_check_mark:| VideoPlayer | `player: AVPlayer?`, `videoOverlay view` |
|:white_check_mark:| ZStack | `contained view`, `alignment: Alignment` |

(*) The following attributes are available directly for the `Font` and `Image` SwiftUI types, as opposed to the attributes available for wrapper views extracted from the hierarchy. In case you obtained an image view from the hierarchy using `image()` call, you'd need to additionally call `actualImage: Image` to get the genuine `Image` structure.

## Property Wrappers

| Status | Modifier |
|:---:|---|
|:technologist:| `@AccessibilityFocusState` |
|:technologist:| `@AppStorage` |
|:white_check_mark:| `@Binding` |
|:white_check_mark:| `@Environment` |
|:white_check_mark:| `@EnvironmentObject` |
|:technologist:| `@FetchRequest` |
|:technologist:| `@FocusState` |
|:technologist:| `@FocusedBinding` |
|:technologist:| `@FocusedValue` |
|:white_check_mark:| `@GestureState` |
|:technologist:| `@Namespace` |
|:white_check_mark:| `@ObservedObject` |
|:technologist:| `@ScaledMetric` |
|:technologist:| `@SceneStorage` |
|:technologist:| `@SectionedFetchRequest` |
|:white_check_mark:| `@State` |
|:technologist:| `@StateObject` |
|:technologist:| `@UIApplicationDelegateAdaptor` |

## Gestures

| Status | Modifier |
|:---:|---|
|:white_check_mark:| `AnyGesture` |
|:white_check_mark:| `DragGesture` |
|:white_check_mark:| `ExclusiveGesture` |
|:white_check_mark:| `GestureStateGesture` |
|:white_check_mark:| `LongPressGesture` |
|:white_check_mark:| `MagnificationGesture` |
|:white_check_mark:| `RotationGesture` |
|:white_check_mark:| `SequenceGesture` |
|:white_check_mark:| `SimultaneousGesture` |
|:white_check_mark:| `TapGesture` |

## View Modifiers

### Custom View Modifiers

| Status | Modifier |
|:---:|---|
|:white_check_mark:| `func modifier<T>(T) -> ModifiedContent<Self, T>` |
|:technologist:| `func concat<T>(_ modifier: T) -> ModifiedContent<Self, T>` |

### Inspecting Views

| Status | Modifier |
|:---:|---|
|:white_check_mark:| `func id<ID>(ID) -> some View` |
|:white_check_mark:| `func equatable() -> EquatableView<Self>` |

### Hiding and Disabling Views

| Status | Modifier |
|:---:|---|
|:white_check_mark:| `func hidden() -> some View` |
|:white_check_mark:| `func disabled(Bool) -> some View` |

### Sizing and Positioning a View

| Status | Modifier |
|:---:|---|
|:white_check_mark:| `func frame(...) -> some View` |
|:white_check_mark:| `func fixedSize(...) -> some View` |
|:white_check_mark:| `func layoutPriority(Double) -> some View` |
|:white_check_mark:| `func position(...) -> some View` |
|:white_check_mark:| `func offset(...) -> some View` |
|:white_check_mark:| `func edgesIgnoringSafeArea(Edge.Set) -> some View` |
|:white_check_mark:| `func coordinateSpace<T>(name: T) -> some View` |
|:technologist:| `func ignoresSafeArea(SafeAreaRegions, edges: Edge.Set) -> some View` |
|:technologist:| `func safeAreaInset(edge: VerticalEdge, alignment: HorizontalAlignment, spacing: CGFloat?, content: () -> V) -> some View` |
|:technologist:| `func alignmentGuide(...) -> some View` |
|:white_check_mark:| `func padding(...) -> some View` |
|:technologist:| `func scenePadding(_ edges: Edge.Set) -> some View` |

### Layering Views

| Status | Modifier |
|:---:|---|
|:white_check_mark:| `func overlay<Overlay>(Overlay, alignment: Alignment) -> some View` |
|:technologist:| `func overlay<S>(_ style: S, ignoresSafeAreaEdges edges: Edge.Set) -> some View` |
|:white_check_mark:| `func background<Background>(Background, alignment: Alignment) -> some View` |
|:technologist:| `func background<S>(_ style: S, ignoresSafeAreaEdges: Edge.Set) -> some View` |
|:white_check_mark:| `func zIndex(Double) -> some View` |
|:technologist:| `func badge(...) -> some View` |
|:white_check_mark:| `func border<S>(S, width: CGFloat) -> some View` |

### Masking and Clipping Views

| Status | Modifier |
|:---:|---|
|:white_check_mark:| `func clipped(antialiased: Bool) -> some View` |
|:white_check_mark:| `func clipShape<S>(S, style: FillStyle) -> some View` |
|:white_check_mark:| `func cornerRadius(CGFloat, antialiased: Bool) -> some View` |
|:white_check_mark:| `func mask<Mask>(Mask) -> some View` |
|:technologist:| `func mask(alignment: Alignment = .center, mask: () -> Mask) -> some View` |
|:technologist:| `func containerShape<T>(_ shape: T) -> some View` |

### Scaling Views

| Status | Modifier |
|:---:|---|
|:white_check_mark:| `func scaledToFill() -> some View` |
|:white_check_mark:| `func scaledToFit() -> some View` |
|:white_check_mark:| `func scaleEffect(...) -> some View` |
|:white_check_mark:| `func aspectRatio(...) -> some View` |
|:white_check_mark:| `func imageScale(Image.Scale) -> some View` |

### Rotating and Transforming Views

| Status | Modifier |
|:---:|---|
|:white_check_mark:| `func rotationEffect(Angle, anchor: UnitPoint) -> some View` |
|:white_check_mark:| `func rotation3DEffect(...) -> some View` |
|:white_check_mark:| `func projectionEffect(ProjectionTransform) -> some View` |
|:white_check_mark:| `func transformEffect(CGAffineTransform) -> some View` |
|:technologist:| `func dynamicTypeSize<T>(...) -> some View` |

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
|:technologist:| `func compositingGroup() -> some View` |
|:technologist:| `func drawingGroup(opaque: Bool, colorMode: ColorRenderingMode) -> some View` |

### Adding Animations to a View

| Status | Modifier |
|:---:|---|
|:technologist:| `func animation(Animation?) -> some View` |
|:technologist:| `func animation<V>(Animation?, value: V) -> some View` |
|:technologist:| `func animation(_ animation: Animation?) -> some ViewModifier` |
|:white_check_mark:| `func transition(AnyTransition) -> some View` |
|:white_check_mark:| `func transaction((inout Transaction) -> Void) -> some View` |
|:technologist:| `func transaction((inout Transaction) -> Void) -> some ViewModifier` |
|:technologist:| `func matchedGeometryEffect<ID>(id: ID, in: Namespace.ID, properties: MatchedGeometryProperties, anchor: UnitPoint, isSource: Bool) -> some View` |

### Handling View Taps and Gestures

| Status | Modifier |
|:---:|---|
|:white_check_mark:| `func onTapGesture(count: Int, perform: () -> Void) -> some View` |
|:white_check_mark:| `func onLongPressGesture(minimumDuration: Double, maximumDistance: CGFloat, pressing: ((Bool) -> Void)?, perform: () -> Void) -> some View` |
|:white_check_mark:| `func gesture<T>(T, including: GestureMask) -> some View` |
|:white_check_mark:| `func highPriorityGesture<T>(T, including: GestureMask) -> some View` |
|:white_check_mark:| `func simultaneousGesture<T>(T, including: GestureMask) -> some View` |

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
|:technologist:| `func onPasteCommand(...) -> some View` |
|:white_check_mark:| `func onDeleteCommand(perform: (() -> Void)?) -> some View` |
|:white_check_mark:| `func onMoveCommand(perform: ((MoveCommandDirection) -> Void)?) -> some View` |
|:white_check_mark:| `func onExitCommand(perform: (() -> Void)?) -> some View` |
|:technologist:| `func onPlayPauseCommand(perform: (() -> Void)?) -> some View` |
|:technologist:| `func onCommand(Selector, perform: (() -> Void)?) -> some View` |
|:technologist:| `func onDrag(() -> NSItemProvider) -> some View` |
|:technologist:| `func onDrop(of: [UTType], ...) -> some View` |
|:technologist:| `func deleteDisabled(Bool) -> some View` |
|:technologist:| `func moveDisabled(Bool) -> some View` |

### Handling Publisher Events

| Status | Modifier |
|:---:|---|
|:white_check_mark:| `func onReceive<P>(P, perform: (P.Output) -> Void) -> some View` |
|:white_check_mark:| `func onChange<V>(of: V, perform: (V) -> Void) -> some View` |
|:technologist:| `func task(...) -> some View` |

### Handling View Hover and Focus

| Status | Modifier |
|:---:|---|
|:technologist:| `func hoverEffect(HoverEffect) -> some View` |
|:technologist:| `func onHover(perform: (Bool) -> Void) -> some View` |
|:technologist:| `func focusedValue<Value>(WritableKeyPath<FocusedValues, Value?>, Value) -> some View` |
|:technologist:| `func prefersDefaultFocus(Bool, in: Namespace.ID) -> some View` |
|:technologist:| `func focusScope(Namespace.ID) -> some View` |
|:technologist:| `func focusSection() -> some View` |
|:white_check_mark:| `func focusable(Bool, onFocusChange: (Bool) -> Void) -> some View` |
|:technologist:| `func focusable(_ isFocusable: Bool) -> some View` |
|:technologist:| `func focused(...) -> some View` |
|:technologist:| `func focusedSceneValue<T>(_ keyPath: WritableKeyPath<FocusedValues, T?>, _ value: T) -> some View` |

### Configuring a View for Hit Testing

| Status | Modifier |
|:---:|---|
|:white_check_mark:| `func allowsHitTesting(Bool) -> some View` |
|:white_check_mark:| `func contentShape<S>(S, eoFill: Bool) -> some View` |
|:technologist:| `func contentShape<S>(_ kind: ContentShapeKinds, _ shape: S, eoFill: Bool) -> some View` |

### Presenting system popup views

| Status | Modifier |
|:---:|---|
|:white_check_mark:| `func actionSheet(isPresented: Binding<Bool>, content: () -> ActionSheet) -> some View` |
|:white_check_mark:| `func actionSheet<T>(item: Binding<T?>, content: (T) -> ActionSheet) -> some View` |
|:white_check_mark:| `func sheet<Content>(isPresented: Binding<Bool>, onDismiss: (() -> Void)?, content: () -> Content) -> some View` |
|:white_check_mark:| `func sheet<Item, Content>(item: Binding<Item?>, onDismiss: (() -> Void)?, content: (Item) -> Content) -> some View` |
|:white_check_mark:| `func fullScreenCover<Content>(isPresented: Binding<Bool>, onDismiss: (() -> Void)?, content: () -> Content) -> some View` |
|:white_check_mark:| `func fullScreenCover<Item, Content>(item: Binding<Item?>, onDismiss: (() -> Void)?, content: (Item) -> Content) -> some View` |
|:white_check_mark:| `func alert(isPresented: Binding<Bool>, content: () -> Alert) -> some View` |
|:white_check_mark:| `func alert<Item>(item: Binding<Item?>, content: (Item) -> Alert) -> some View` |
|:white_check_mark:| `func popover<Content>(isPresented: Binding<Bool>, attachmentAnchor: PopoverAttachmentAnchor, arrowEdge: Edge, content: () -> Content) -> some View` |
|:white_check_mark:| `func popover<Item, Content>(item: Binding<Item?>, attachmentAnchor: PopoverAttachmentAnchor, arrowEdge: Edge, content: (Item) -> Content) -> some View` |
|:white_check_mark:| `func confirmationDialog<S, A, M>(_ title: S, isPresented: Binding<Bool>, titleVisibility: Visibility, @ViewBuilder actions: () -> A, @ViewBuilder message: () -> M) -> some View` |
|:technologist:| `func interactiveDismissDisabled(_ isDisabled: Bool) -> some View` |

### Setting View Preferences

| Status | Modifier |
|:---:|---|
|:technologist:| `func preference<K>(key: K.Type, value: K.Value) -> some View` |
|:technologist:| `func transformPreference<K>(K.Type, (inout K.Value) -> Void) -> some View` |
|:technologist:| `func anchorPreference<A, K>(key: K.Type, value: Anchor<A>.Source, transform: (Anchor<A>) -> K.Value) -> some View` |
|:technologist:| `func transformAnchorPreference<A, K>(key: K.Type, value: Anchor<A>.Source, transform: (inout K.Value, Anchor<A>) -> Void) -> some View` |
|:technologist:| `func onPreferenceChange<K>(K.Type, perform: (K.Value) -> Void) -> some View` |
|:white_check_mark:| `func backgroundPreferenceValue<Key, T>(Key.Type, (Key.Value) -> T) -> some View` |
|:white_check_mark:| `func overlayPreferenceValue<Key, T>(Key.Type, (Key.Value) -> T) -> some View` |

### Setting the Environment Values of a View

| Status | Modifier |
|:---:|---|
|:white_check_mark:| `func environmentObject<B>(B) -> some View` |
|:technologist:| `func environment<V>(WritableKeyPath<EnvironmentValues, V>, V) -> some View` |
|:technologist:| `func transformEnvironment<V>(WritableKeyPath<EnvironmentValues, V>, transform: (inout V) -> Void) -> some View` |

### Setting View Colors

| Status | Modifier |
|:---:|---|
|:white_check_mark:| `func foregroundColor(Color?) -> some View` |
|:technologist:| `func foregroundStyle(...) -> some View` |
|:white_check_mark:| `func accentColor(Color?) -> some View` |
|:white_check_mark:| `func tint(Color?) -> some View` |
|:white_check_mark:| `func listItemTint(Color?) -> some View` |
|:technologist:| `func symbolRenderingMode(_ mode: SymbolRenderingMode?) -> some View` |
|:technologist:| `func symbolVariant(_ variant: SymbolVariants) -> some View` |
|:white_check_mark:| `func colorScheme(ColorScheme) -> some View` |
|:white_check_mark:| `func preferredColorScheme(ColorScheme?) -> some View` |

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

### Adjusting Text in a View

| Status | Modifier |
|:---:|---|
|:white_check_mark:| `func keyboardType(UIKeyboardType) -> some View` |
|:white_check_mark:| `func font(Font?) -> some View` |
|:white_check_mark:| `func lineLimit(Int?) -> some View` |
|:white_check_mark:| `func lineSpacing(CGFloat) -> some View` |
|:white_check_mark:| `func multilineTextAlignment(TextAlignment) -> some View` |
|:white_check_mark:| `func minimumScaleFactor(CGFloat) -> some View` |
|:white_check_mark:| `func truncationMode(Text.TruncationMode) -> some View` |
|:white_check_mark:| `func allowsTightening(Bool) -> some View` |
|:white_check_mark:| `func textContentType(UITextContentType?) -> some View` |
|:technologist:| `func textContentType(UITextContentType?) -> some View` |
|:technologist:| `func textCase(Text.Case?) -> some View` |
|:white_check_mark:| `func flipsForRightToLeftLayoutDirection(Bool) -> some View` |
|:white_check_mark:| `func autocapitalization(UITextAutocapitalizationType) -> some View` |
|:white_check_mark:| `func disableAutocorrection(Bool?) -> some View` |
|:technologist:| `func monospacedDigit() -> some View` |
|:technologist:| `func textInputAutocapitalization(_ autocapitalization: TextInputAutocapitalization?) -> some View` |
|:technologist:| `func onSubmit(of triggers: SubmitTriggers, _ action: @escaping (() -> Void)) -> some View` |
|:technologist:| `func submitLabel(_ submitLabel: SubmitLabel) -> some View` |
|:technologist:| `func submitScope(_ isBlocking: Bool) -> some View` |
|:technologist:| `func textSelection<S>(_ selectability: S) -> some View` |

### Redacting Content

| Status | Modifier |
|:---:|---|
|:technologist:| `func redacted(reason: RedactionReasons) -> some View` |
|:technologist:| `func unredacted() -> some View` |
|:technologist:| `func privacySensitive(_ sensitive: Bool) -> some View` |

### Configuring Control Attributes

| Status | Modifier |
|:---:|---|
|:white_check_mark:| `func labelsHidden() -> some View` |
|:white_check_mark:| `func horizontalRadioGroupLayout() -> some View` |
|:white_check_mark:| `func controlSize(ControlSize) -> some View` |

### Styling Specific View Types

| Status | Modifier |
|:---:|---|
|:white_check_mark:| `func buttonStyle<S>(S) -> some View` |
|:white_check_mark:| `func datePickerStyle<S>(S) -> some View` |
|:white_check_mark:| `func groupBoxStyle<S>(S) -> some View` |
|:white_check_mark:| `func indexViewStyle<S>(S) -> some View` |
|:white_check_mark:| `func labelStyle<S>(S) -> some View` |
|:white_check_mark:| `func listStyle<S>(S) -> some View` |
|:white_check_mark:| `func menuButtonStyle<S>(S) -> some View` |
|:white_check_mark:| `func menuStyle<S>(S) -> some View` |
|:white_check_mark:| `func navigationViewStyle<S>(S) -> some View` |
|:white_check_mark:| `func pickerStyle<S>(S) -> some View` |
|:technologist:| `func presentedWindowStyle<S>(S) -> some View` |
|:technologist:| `func presentedWindowToolbarStyle<S>(S) -> some View` |
|:white_check_mark:| `func progressViewStyle<S>(S) -> some View` |
|:white_check_mark:| `func tabViewStyle<S>(S) -> some View` |
|:white_check_mark:| `func textFieldStyle<S>(S) -> some View` |
|:white_check_mark:| `func toggleStyle<S>(S) -> some View` |
|:technologist:| `func controlGroupStyle<S>(S) -> some View` |
|:technologist:| `func gaugeStyle<S>(S) -> some View` |
|:technologist:| `func signInWithAppleButtonStyle(S) -> some View` |
|:technologist:| `func buttonBorderShape(_ shape: ButtonBorderShape) -> some View` |

### Configuring a List View

| Status | Modifier |
|:---:|---|
|:white_check_mark:| `func listRowInsets(EdgeInsets?) -> some View` |
|:white_check_mark:| `func listRowBackground<V>(V?) -> some View` |
|:technologist:| `func listRowPlatterColor(Color?) -> some View` |
|:white_check_mark:| `func tag<V>(V) -> some View` |
|:technologist:| `func swipeActions<T>(edge: HorizontalEdge, allowsFullSwipe: Bool, content: () -> T) -> some View` |
|:technologist:| `func listRowSeparator(_ visibility: Visibility, edges: VerticalEdge.Set) -> some View` |
|:technologist:| `func listRowSeparatorTint(_ color: Color?, edges: VerticalEdge.Set) -> some View` |
|:technologist:| `func listSectionSeparator(_ visibility: Visibility, edges: VerticalEdge.Set) -> some View` |
|:technologist:| `func listSectionSeparatorTint(_ color: Color?, edges: VerticalEdge.Set) -> some View` |
|:technologist:| `func headerProminence(_ prominence: Prominence) -> some View` |
|:technologist:| `func refreshable(action: @Sendable () async -> Void) -> some View` |
|:technologist:| `func searchable(text: Binding<String>, placement: SearchFieldPlacement, prompt: LocalizedStringKey) -> some View` |
|:technologist:| `func searchCompletion(_ completion: String) -> some View` |

### Configuring Navigation, Status and Tab Bars

| Status | Modifier |
|:---:|---|
|:white_check_mark:| `func navigationBarItems(...) -> some View` |
|:technologist:| `func navigationBarTitle(...) -> some View` |
|:technologist:| `func navigationTitle(...) -> some View` |
|:technologist:| `func navigationSubtitle(...) -> some View` |
|:technologist:| `func navigationBarTitleDisplayMode(NavigationBarItem.TitleDisplayMode) -> some View` |
|:white_check_mark:| `func navigationBarHidden(Bool) -> some View` |
|:white_check_mark:| `func navigationBarBackButtonHidden(Bool) -> some View` |
|:white_check_mark:| `func toolbar<Content>(content: () -> Content) -> some View` |
|:white_check_mark:| `func toolbar<Content>(content: () -> Content) -> some View` |
|:white_check_mark:| `func toolbar<Content>(id: String, content: () -> Content) -> some View` |
|:white_check_mark:| `func tabItem<V>(() -> V) -> some View` |
|:white_check_mark:| `func statusBar(hidden: Bool) -> some View` |

### Configuring Touch Bar Views

| Status | Modifier |
|:---:|---|
|:white_check_mark:| `func touchBar(...) -> some View` |
|:white_check_mark:| `func touchBarItemPrincipal(Bool) -> some View` |
|:white_check_mark:| `func touchBarCustomizationLabel(Text) -> some View` |
|:white_check_mark:| `func touchBarItemPresence(TouchBarItemPresence) -> some View` |

### Handling Keyboard Shortcuts

| Status | Modifier |
|:---:|---|
|:technologist:| `func keyboardShortcut(KeyboardShortcut) -> some View` |
|:technologist:| `func keyboardShortcut(KeyEquivalent, modifiers: EventModifiers) -> some View` |

### Configuring Context Menu Views

| Status | Modifier |
|:---:|---|
|:technologist:| `func contextMenu(...) -> some View` |
|:technologist:| `func menuIndicator(_ visibility: Visibility) -> some View` |
|:technologist:| `func help(...) -> some View` |

### Customizing Accessibility

| Status | Modifier |
|:---:|---|
|:white_check_mark:| `func accessibilityLabel(...) -> some View` |
|:white_check_mark:| `func accessibilityValue(...) -> some View` |
|:white_check_mark:| `func accessibilityHidden(Bool) -> some View` |
|:white_check_mark:| `func accessibilityIdentifier(String) -> some View` |
|:white_check_mark:| `func accessibilityHint(...) -> some View` |
|:white_check_mark:| `func accessibilityActivationPoint(...) -> some View` |
|:white_check_mark:| `func accessibilityAction(...) -> some View` |
|:technologist:| `func accessibilityAction<Label>(action: () -> Void, label: () -> Label) -> some View` |
|:technologist:| `func accessibilityAction<S>(named name: S, () -> Void) -> some View` |
|:white_check_mark:| `func accessibilityAdjustableAction((AccessibilityAdjustmentDirection) -> Void) -> some View` |
|:white_check_mark:| `func accessibilityScrollAction((Edge) -> Void) -> some View` |
|:white_check_mark:| `func accessibilitySortPriority(Double) -> some View` | |
|:technologist:| `func accessibilityIgnoresInvertColors(Bool) -> some View` |
|:technologist:| `func accessibilityLabeledPair<ID>(role: AccessibilityLabeledPairRole, id: ID, in: Namespace.ID) -> some View` |
|:technologist:| `func accessibilityChartDescriptor<R>(_ representable: R) -> some View` |
|:technologist:| `func accessibilityHeading(_ level: AccessibilityHeadingLevel) -> some View` |
|:technologist:| `func accessibilityTextContentType(_ textContentType: AccessibilityTextContentType) -> some View` |
|:technologist:| `func accessibilityCustomContent(...) -> some View` |
|:technologist:| `func accessibilityRepresentation<V>(representation: () -> V) -> some View` |
|:technologist:| `func accessibilityRespondsToUserInteraction(_ respondsToUserInteraction: Bool) -> some View` |
|:technologist:| `func accessibilityFocused(...) -> some View` |
|:technologist:| `func accessibilityRotor(...) -> some View` |
|:technologist:| `func accessibilityElement(children: AccessibilityChildBehavior) -> some View` |
|:technologist:| `func accessibilityChildren<V>(children: () -> V) -> some View` |
|:technologist:| `func accessibilityInputLabels(...) -> some View` |
|:technologist:| `func accessibilityAddTraits(AccessibilityTraits) -> some View` |
|:technologist:| `func accessibilityRemoveTraits(AccessibilityTraits) -> some View` |
|:technologist:| `func accessibilityLinkedGroup<ID>(id: ID, in: Namespace.ID) -> some View` |
|:technologist:| `func accessibilityShowsLargeContentViewer(...) -> some View` |
|:technologist:| `func speechAdjustedPitch(_ value: Double) -> some View` |
|:technologist:| `func speechAlwaysIncludesPunctuation(_ value: Bool) -> some View` |
|:technologist:| `func speechAnnouncementsQueued(_ value: Bool) -> some View` |
|:technologist:| `func speechSpellsOutCharacters(_ value: Bool) -> some View` |

### Configuring View Previews

| Status | Modifier |
|:---:|---|
|:white_check_mark:| `func previewDevice(PreviewDevice?) -> some View` |
|:white_check_mark:| `func previewDisplayName(String?) -> some View` |
|:white_check_mark:| `func previewLayout(PreviewLayout) -> some View` |
|:technologist:| `func previewContext<C>(C) -> some View` |
|:technologist:| `func previewInterfaceOrientation(_ value: InterfaceOrientation) -> some View` |

### Presenting File Management Interfaces

| Status | Modifier |
|:---:|---|
|:technologist:| `func fileExporter(...) -> some View` |
|:technologist:| `func fileImporter(...) -> some View` |
|:technologist:| `func fileMover(...) -> some View` |
|:technologist:| `func exportsItemProviders(_ contentTypes: [UTType], onExport: @escaping () -> [NSItemProvider]) -> some View` |
|:technologist:| `func importsItemProviders(_ contentTypes: [UTType], onImport: @escaping ([NSItemProvider]) -> Bool) -> some View` |
|:technologist:| `func itemProvider(Optional<() -> NSItemProvider?>) -> some View` |
|:technologist:| `func defaultAppStorage(UserDefaults) -> some View` |

### watchOS View Modifiers

| Status | Modifier |
|:---:|---|
|:technologist:| `func complicationForeground() -> some View` |
|:technologist:| `func defaultWheelPickerItemHeight(_ height: CGFloat) -> some View` |
|:technologist:| `func pageCommand<V>(value: Binding<V>, in bounds: ClosedRange<V>, step: V) -> some View` |
|:technologist:| `func digitalCrownRotation<V>(_ binding: Binding<V>) -> some View` |

### APIs from other Frameworks

| Status | Modifier |
|:---:|---|
|:technologist:| `func appStoreOverlay(isPresented: Binding<Bool>, configuration: @escaping () -> SKOverlay.Configuration) -> some View` |
|:technologist:| `func manageSubscriptionsSheet(isPresented: Binding<Bool>) -> some View` |
|:technologist:| `func refundRequestSheet(for transactionID: UInt64, isPresented: Binding<Bool>, onDismiss: ...) -> some View` |
|:technologist:| `func quickLookPreview<Items>(_ selection: Binding<Items.Element?>, in items: Items) -> some View` |
|:technologist:| `func quickLookPreview(_ item: Binding<URL?>) -> some View` |
|:technologist:| `func signInWithAppleButtonStyle(_ style: SignInWithAppleButton.Style) -> some View` |
|:technologist:| `func musicSubscriptionOffer(isPresented: Binding<Bool>, options: ..., onLoadCompletion: ...) -> some View` |

## Other UI entities

| Status | Modifier |
|:---:|---|
|:technologist:| Widget |
|:technologist:| Scene |
|:technologist:| DocumentGroup |
|:technologist:| Settings |
|:technologist:| WKNotificationScene |
|:technologist:| WindowGroup |

### WidgetConfiguration

| Status | Modifier |
|:---:|---|
|:technologist:| `func configurationDisplayName(...) -> some WidgetConfiguration` |
|:technologist:| `func description(...) -> some WidgetConfiguration` |
|:technologist:| `func onBackgroundURLSessionEvents(...) -> some WidgetConfiguration` |
|:technologist:| `func supportedFamilies(_ families: [WidgetFamily]) -> some WidgetConfiguration` |
