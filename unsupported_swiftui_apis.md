# Unsupported SwiftUI APIs for ViewInspector

This file contains a comprehensive list of SwiftUI APIs that are not yet supported or only partially supported by ViewInspector. Each entry can be used as input for the `/new-api-support` skill.

Generated from Xcode 26.2.0 SDK (iOS 18+).

---

## View Types - Not Supported

### Core SwiftUI Views

```
AccessoryWidgetBackground
Chart
Chart3D
Gauge
KeyframeAnimator
PhaseAnimator
RenameButton
SettingsLink
Table
TextFieldLink
WindowVisibilityToggle
```

### Platform-Specific Views

```
CameraView (visionOS)
DocumentLaunchView
HelpLink
NewDocumentButton
```

### StoreKit Views

```
PayWithApplePayButton
ProductView
SubscriptionStoreView
SubscriptionStoreButton
SubscriptionOfferView
SubscriptionStorePickerOption
```

### PassKit Views

```
AddPassToWalletButton
VerifyIdentityWithWalletButton
PayLaterView
AsyncShareablePassConfiguration
```

### PhotosUI Views

```
PhotosPicker
```

### MusicKit Views

```
ArtworkImage
NowPlayingView
MusicSubscriptionOffer
```

### DeviceActivity Views

```
FamilyActivityPicker
DevicePicker
```

### Authentication Views

```
LocalAuthenticationView
SignInWithAppleButton (partial - style modifier missing)
```

### SceneKit/SpriteKit Views

```
SceneView
SpriteView
```

### Other Framework Views

```
ShortcutsLink
SiriTipView
QuickLookPreview
```

---

## View Types - Partial Support

These views have basic support but are missing specific initializers or APIs.

### Group

```
Group(subviews:transform:)
Group(sections:transform:)
```

Current support: Basic `Group(@ViewBuilder content:)` only.

### ForEach

```
ForEach(subviewOf:content:)
ForEach(sectionOf:content:)
```

Current support: Basic collection-based ForEach.

### ScrollView

```
scrollPosition(id:)
scrollTargetLayout()
scrollTargetBehavior()
```

Current support: Basic ScrollView with axes and indicators.

### List

```
List(selection:content:)
List editing actions (swipeActions, etc.)
```

### NavigationStack

```
navigationDestination(for:destination:)
navigationDestination(isPresented:destination:)
```

### TabView

```
Tab (iOS 18+) - partial
TabSection
tabViewCustomization()
```

### TimelineView

```
TimelineView with custom schedules
```

---

## View Modifiers - Not Supported

### Layout & Positioning

```
ignoresSafeArea(_:edges:)
safeAreaInset(edge:alignment:spacing:content:)
alignmentGuide(_:computeValue:)
scenePadding(_:edges:)
containerRelativeFrame(_:alignment:)
contentMargins(_:for:)
```

### Layering & Appearance

```
overlay(_:ignoresSafeAreaEdges:) - style variant
background(_:ignoresSafeAreaEdges:) - style variant
badge(_:)
mask(alignment:_:) - closure variant
containerShape(_:)
visualEffect(_:)
```

### Animation

```
animation(_:) - deprecated but used
animation(_:value:)
matchedGeometryEffect(id:in:properties:anchor:isSource:)
contentTransition(_:)
phaseAnimator(_:content:animation:)
keyframeAnimator(initialValue:repeating:content:keyframes:)
```

### Graphics & Effects

```
compositingGroup()
drawingGroup(opaque:colorMode:)
symbolRenderingMode(_:)
symbolVariant(_:)
dynamicTypeSize(_:)
```

### Text

```
textCase(_:)
monospacedDigit()
textInputAutocapitalization(_:)
textSelection(_:)
writingToolsBehavior(_:)
```

### Submission & Focus

```
onSubmit(of:_:)
submitLabel(_:)
submitScope(_:)
focused(_:)
focusedValue(_:_:)
focusScope(_:)
focusSection()
prefersDefaultFocus(_:in:)
```

### Hover & Pointer

```
hoverEffect(_:)
onHover(perform:)
onContinuousHover(coordinateSpace:perform:)
pointerVisibility(_:)
```

### Gestures & Input

```
onDrag(_:)
onDrop(of:delegate:)
onPasteCommand(of:perform:)
onPlayPauseCommand(perform:)
onCommand(_:perform:)
keyboardShortcut(_:)
keyboardShortcut(_:modifiers:)
onKeyPress(_:action:)
```

### Context Menu

```
contextMenu(menuItems:)
contextMenu(menuItems:preview:)
menuIndicator(_:)
```

### List Configuration

```
listRowPlatterColor(_:)
listRowSeparator(_:edges:)
listRowSeparatorTint(_:edges:)
listSectionSeparator(_:edges:)
listSectionSeparatorTint(_:edges:)
swipeActions(edge:allowsFullSwipe:content:)
headerProminence(_:)
searchable(text:placement:prompt:)
searchCompletion(_:)
searchSuggestions(_:)
```

### Navigation

```
navigationTitle(_:) - Text/LocalizedStringKey variants
navigationSubtitle(_:)
navigationBarTitle(_:displayMode:)
navigationBarTitleDisplayMode(_:)
navigationDocument(_:)
toolbarBackground(_:for:)
toolbarBackgroundVisibility(_:for:)
toolbarColorScheme(_:for:)
toolbarRole(_:)
toolbarTitleDisplayMode(_:)
toolbarVisibility(_:for:)
```

### Presentation

```
interactiveDismissDisabled(_:)
presentationDetents(_:)
presentationDragIndicator(_:)
presentationCornerRadius(_:)
presentationBackgroundInteraction(_:)
presentationContentInteraction(_:)
presentationCompactAdaptation(_:)
presentationSizing(_:)
```

### Scroll

```
scrollDisabled(_:)
scrollDismissesKeyboard(_:)
scrollIndicators(_:axes:)
scrollClipDisabled(_:)
scrollContentBackground(_:)
scrollBounceBehavior(_:axes:)
scrollPosition(id:anchor:)
scrollTargetBehavior(_:)
scrollTargetLayout(isEnabled:)
scrollTransition(_:)
```

### Accessibility

```
accessibilityElement(children:)
accessibilityChildren(children:)
accessibilityRepresentation(representation:)
accessibilityInputLabels(_:)
accessibilityAddTraits(_:)
accessibilityRemoveTraits(_:)
accessibilityLinkedGroup(id:in:)
accessibilityLabeledPair(role:id:in:)
accessibilityRotor(_:entries:)
accessibilityFocused(_:)
accessibilityChartDescriptor(_:)
accessibilityCustomContent(_:_:)
accessibilityIgnoresInvertColors(_:)
speechAdjustedPitch(_:)
speechAlwaysIncludesPunctuation(_:)
speechAnnouncementsQueued(_:)
speechSpellsOutCharacters(_:)
```

### Environment

```
environment(_:_:)
transformEnvironment(_:transform:)
```

### Preferences

```
preference(key:value:)
transformPreference(_:_:)
anchorPreference(key:value:transform:)
transformAnchorPreference(key:value:transform:)
onPreferenceChange(_:perform:)
```

### Lifecycle

```
userActivity(_:element:_:)
userActivity(_:isActive:_:)
onContinueUserActivity(_:perform:)
onOpenURL(perform:)
widgetURL(_:)
handlesExternalEvents(preferring:allowing:)
```

### Drag & Drop

```
onDrag(_:preview:)
onDrop(of:isTargeted:perform:)
itemProvider(_:)
exportsItemProviders(_:onExport:)
importsItemProviders(_:onImport:)
draggable(_:)
dropDestination(for:action:)
```

### Control Styling

```
controlGroupStyle(_:)
gaugeStyle(_:)
signInWithAppleButtonStyle(_:)
buttonBorderShape(_:)
buttonRepeatBehavior(_:)
textEditorStyle(_:)
```

### File Operations

```
fileExporter(isPresented:document:contentType:defaultFilename:onCompletion:)
fileImporter(isPresented:allowedContentTypes:allowsMultipleSelection:onCompletion:)
fileMover(isPresented:file:onCompletion:)
```

### Redaction

```
redacted(reason:)
unredacted()
privacySensitive(_:)
invalidatableContent(_:)
```

### Sensory Feedback

```
sensoryFeedback(_:trigger:)
sensoryFeedback(_:trigger:condition:)
```

### Preview

```
previewContext(_:)
previewInterfaceOrientation(_:)
```

### watchOS Specific

```
digitalCrownRotation(_:)
defaultWheelPickerItemHeight(_:)
```

### Window Management (macOS/iPadOS)

```
windowResizability(_:)
windowLevel(_:)
defaultSize(_:)
defaultPosition(_:)
windowToolbarStyle(_:)
windowStyle(_:)
```

### Other Modifiers

```
renameAction(_:)
refreshable(action:) - async variant improvements
deleteDisabled(_:)
moveDisabled(_:)
defaultAppStorage(_:)
findNavigator(isPresented:)
findDisabled(_:)
replaceDisabled(_:)
persistentSystemOverlays(_:)
defersSystemGestures(on:)
alternatingRowBackgrounds(_:)
dialogSeverity(_:)
dialogSuppressionToggle(_:isSuppressed:)
inspector(isPresented:content:)
inspectorColumnWidth(_:)
```

---

## Property Wrappers - Not Supported

```
@AccessibilityFocusState
@AppStorage
@FetchRequest
@FocusedBinding
@FocusedObject
@FocusedValue
@FocusState
@Namespace
@NSApplicationDelegateAdaptor
@ScaledMetric
@SceneStorage
@SectionedFetchRequest
@StateObject
@UIApplicationDelegateAdaptor
@WKApplicationDelegateAdaptor
@WKExtensionDelegateAdaptor
```

---

## Gestures - Not Supported

```
MagnifyGesture (renamed from MagnificationGesture)
RotateGesture (renamed from RotationGesture)
WindowDragGesture
SpatialEventGesture
```

---

## Scenes - Not Supported

```
WindowGroup
Window
DocumentGroup
Settings
MenuBarExtra
ImmersiveSpace
AlertScene
AssistiveAccess
UtilityWindow
```

---

## Charts Framework

```
Chart
Chart3D
AxisValueLabel
ChartPlotContent
BarMark
LineMark
PointMark
AreaMark
RuleMark
RectangleMark
SectorMark
```

---

## Quick Reference for /new-api-support

Below are prioritized items that can be directly used with the skill:

### High Priority (Commonly Used)

```
/new-api-support Gauge
/new-api-support Table
/new-api-support PhotosPicker
/new-api-support Chart
/new-api-support searchable
/new-api-support swipeActions
/new-api-support contextMenu
/new-api-support presentationDetents
/new-api-support scrollPosition
/new-api-support focused
```

### Medium Priority

```
/new-api-support KeyframeAnimator
/new-api-support PhaseAnimator
/new-api-support RenameButton
/new-api-support TextFieldLink
/new-api-support SettingsLink
/new-api-support badge
/new-api-support matchedGeometryEffect
/new-api-support contentTransition
/new-api-support symbolRenderingMode
/new-api-support ignoresSafeArea
```

### Lower Priority (Specialized)

```
/new-api-support PayWithApplePayButton
/new-api-support AddPassToWalletButton
/new-api-support SceneView
/new-api-support SpriteView
/new-api-support ArtworkImage
/new-api-support FamilyActivityPicker
/new-api-support LocalAuthenticationView
/new-api-support SiriTipView
/new-api-support ShortcutsLink
```

### Partial Support Improvements

```
/new-api-support "Group(subviews:)"
/new-api-support "ScrollView scrollPosition"
/new-api-support "List swipeActions"
/new-api-support "NavigationStack navigationDestination"
/new-api-support "TabView Tab"
```

---

## Notes

1. Some APIs are platform-specific (visionOS, watchOS, macOS only)
2. Some modifiers have multiple overloads - the skill should identify all variants
3. Internal types (prefixed with `_`) are not included
4. Style protocols (ButtonStyle, etc.) are generally supported but specific built-in styles may not be
5. The skill should check `@available` attributes for proper platform/version annotations
