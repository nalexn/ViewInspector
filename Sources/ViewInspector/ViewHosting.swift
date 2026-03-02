import SwiftUI
import Combine
#if canImport(UIKit)
import UIKit
#endif

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
#if swift(>=6.0)
@MainActor
#endif
public enum ViewHosting { }

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension ViewHosting {
    
    struct ViewId: Hashable, Sendable {
        let function: String
        var key: String { function }
    }

    @available(*, deprecated, message: "Use `host` version that doesn't supply the view in the `whileHosted` closure. See: https://github.com/nalexn/ViewInspector/discussions/354")
    @MainActor
    static func host<V>(_ view: V, size: CGSize? = nil,
                        function: String = #function,
                        whileHosted: @MainActor (V) async throws -> Void
    ) async throws where V: View {
        let viewId = ViewId(function: function)
        hostResolvingIfNeeded(view: view, size: size, viewId: viewId)
        try await whileHosted(view)
        expel(viewId: viewId)
    }

    @MainActor
    static func host<V>(_ view: V, size: CGSize? = nil,
                        function: String = #function,
                        whileHosted: @MainActor () async throws -> Void
    ) async throws where V: View {
        try await host(view, size: size, function: function, whileHosted: { _ in
            try await whileHosted()
        })
    }

    static func host<V>(view: V, size: CGSize? = nil, function: String = #function) where V: View {
        let viewId = ViewId(function: function)
        MainActor.assumeIsolated {
            hostResolvingIfNeeded(view: view, size: size, viewId: viewId)
        }
    }

    @MainActor
    private static func hostResolvingIfNeeded<V>(view: V, size: CGSize? = nil, viewId: ViewId) where V: View {
        if ViewInspectorConfig.resolveEnvironmentValues {
            if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *) {
                host(view: EnvironmentInjection.viewWithResolvedEnvironment(view), size: size, viewId: viewId)
            } else {
                host(view: EnvironmentInjection.viewWithResolvedEnvironmentBase(view), size: size, viewId: viewId)
            }
        } else {
            host(view: view, size: size, viewId: viewId)
        }
    }

    @MainActor
    private static func host<V>(view: V, size: CGSize? = nil, viewId: ViewId) where V: View {
        let medium = { () -> Content.Medium in
            guard let unwrapped = try? Inspector.unwrap(view: view, medium: .empty)
            else { return .empty }
            if !unwrapped.isCustomView {
                return unwrapped.medium.removingCustomViewModifiers()
            }
            return unwrapped.medium
        }()
        #if os(watchOS)
        do {
            store(Hosted(medium: medium), viewId: viewId)
            try watchOS(host: AnyView(view), viewId: viewId)
        } catch {
            fatalError(error.localizedDescription)
            /*
             If you're running ViewInspector's tests on watchOS, launch them
             from another Xcode project at ".watchOS/watchOS.xcodeproj"
             */
        }
        #else
        let parentVC = rootViewController
        let childVC = hostVC(view)
        let size = size ?? parentVC.view.bounds.size
        store(Hosted(viewController: childVC, medium: medium), viewId: viewId)
        childVC.view.translatesAutoresizingMaskIntoConstraints = false
        childVC.view.frame = parentVC.view.frame
        willMove(childVC, to: parentVC)
        parentVC.addChild(childVC)
        parentVC.view.addSubview(childVC.view)
        NSLayoutConstraint.activate([
            childVC.view.leadingAnchor.constraint(equalTo: parentVC.view.leadingAnchor),
            childVC.view.topAnchor.constraint(equalTo: parentVC.view.topAnchor),
            childVC.view.widthAnchor.constraint(equalToConstant: size.width).priority(.defaultHigh),
            childVC.view.heightAnchor.constraint(equalToConstant: size.height).priority(.defaultHigh)
        ])
        didMove(childVC, to: parentVC)
        window.layoutIfNeeded()
        #endif
    }

    static func expel(function: String = #function) {
        let viewId = ViewId(function: function)
        MainActor.assumeIsolated {
            expel(viewId: viewId)
        }
    }

    @MainActor
    private static func expel(viewId: ViewId) {
        #if os(watchOS)
        _ = expelHosted(viewId: viewId)
        try? watchOS(host: nil, viewId: viewId)
        #else
        guard let hosted = expelHosted(viewId: viewId) else { return }
        let childVC = hosted.viewController
        willMove(childVC, to: nil)
        childVC.view.removeFromSuperview()
        childVC.removeFromParent()
        didMove(childVC, to: nil)
        #endif
    }
    
    #if os(watchOS)
    private static func watchOS(host view: AnyView?, viewId: ViewId) throws {
        typealias Subject = CurrentValueSubject<[(String, AnyView)], Never>
        guard let subject: Subject = try subjectForWatchOS(type: Subject.self) else {
            throw InspectionError.notSupported(
                """
                View hosting for watchOS is not set up. Please follow this guide: \
                https://github.com/nalexn/ViewInspector/blob/master/guide_watchOS.md
                """)
        }
        var array = subject.value
        if let view = view {
            array.append((viewId.key, view))
        } else if let index = array.firstIndex(where: { $0.0 == viewId.key }) {
            array.remove(at: index)
        }
        subject.send(array)
    }
    #endif

    internal static func medium(function: String = #function) -> Content.Medium {
        let viewId = ViewHosting.ViewId(function: function)
        #if swift(>=6.0)
        return hosted[viewId]?.medium ?? .empty
        #else
        return MainActor.assumeIsolated {
            hosted[viewId]?.medium ?? .empty
        }
        #endif
    }
}

// MARK: - Private

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
@MainActor
private extension ViewHosting {
    
    struct Hosted {
        #if os(macOS)
        let viewController: NSViewController
        #elseif os(iOS) || os(tvOS) || os(visionOS)
        let viewController: UIViewController
        #endif
        let medium: Content.Medium
    }
    private static var hosted: [ViewId: Hosted] = [:]
    #if os(macOS)
    static let window: NSWindow = makeWindow()
    #elseif os(iOS) || os(tvOS) || os(visionOS)
    static let window: UIWindow = makeWindow()
    #endif
    
    // MARK: - Window construction
    
    #if os(macOS)
    static func makeWindow() -> NSWindow {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 200, height: 200),
            styleMask: [.titled, .resizable, .miniaturizable, .closable],
            backing: .buffered,
            defer: false)
        installRootViewController(window)
        window.makeKeyAndOrderFront(window)
        window.layoutIfNeeded()
        return window
    }
    @discardableResult
    static func installRootViewController(_ window: NSWindow) -> NSViewController {
        let vc = RootViewController()
        window.contentViewController = vc
        return vc
    }
    #elseif os(iOS) || os(tvOS) || os(visionOS)
    static func makeWindow() -> UIWindow {
        #if os(visionOS)
        let frame = CGRect(x: 0, y: 0, width: 1280, height: 720)
        #else
        let frame = UIScreen.main.bounds
        #endif
        let window = UIWindow(frame: frame)
        installRootViewController(window)
        window.makeKeyAndVisible()
        window.layoutIfNeeded()
        return window
    }
    @discardableResult
    static func installRootViewController(_ window: UIWindow) -> UIViewController {
        let vc = UIViewController()
        window.rootViewController = vc
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        return vc
    }
    #endif
    
    // MARK: - ViewControllers
    
    #if os(macOS)
    static var rootViewController: NSViewController {
        window.contentViewController ?? installRootViewController(window)
    }
    static func hostVC<V>(_ view: V) -> NSHostingController<V> where V: View {
        NSHostingController(rootView: view)
    }
    #elseif os(iOS) || os(tvOS) || os(visionOS)
    static var rootViewController: UIViewController {
        window.rootViewController ?? installRootViewController(window)
    }
    static func hostVC<V>(_ view: V) -> UIHostingController<V> where V: View {
        UIHostingController(rootView: view)
    }
    #endif
    
    // MARK: - WillMove & DidMove
    
    #if os(macOS)
    static func willMove(_ child: NSViewController, to parent: NSViewController?) {
    }
    static func didMove(_ child: NSViewController, to parent: NSViewController?) {
    }
    #elseif os(iOS) || os(tvOS) || os(visionOS)
    static func willMove(_ child: UIViewController, to parent: UIViewController?) {
        child.willMove(toParent: parent)
    }
    static func didMove(_ child: UIViewController, to parent: UIViewController?) {
        child.didMove(toParent: parent)
    }
    #endif
    
    // MARK: - ViewController identification
    
    static func store(_ hosted: Hosted, viewId: ViewId) {
        self.hosted[viewId] = hosted
    }
    
    static func expelHosted(viewId: ViewId) -> Hosted? {
        return hosted.removeValue(forKey: viewId)
    }
}

#if !os(watchOS)
@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private extension NSLayoutConstraint {
    #if os(macOS)
    func priority(_ value: NSLayoutConstraint.Priority) -> NSLayoutConstraint {
        priority = value
        return self
    }
    #else
    func priority(_ value: UILayoutPriority) -> NSLayoutConstraint {
        priority = value
        return self
    }
    #endif
}
#endif

// MARK: - RootViewController for macOS

#if os(macOS)
@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private class RootViewController: NSViewController {

   override func loadView() {
      view = NSView()
   }

   init() {
      super.init(nibName: nil, bundle: nil)
   }

   required init?(coder: NSCoder) {
      fatalError()
   }
}
#endif

// MARK: - UIView lookup

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 7.0, *)
@MainActor
internal extension ViewHosting {
    #if os(macOS)
    static func lookup<V>(_ view: V.Type) throws -> V.NSViewType
        where V: NSViewRepresentable {
            let name = Inspector.typeName(type: view)
            let viewHost = rootViewController.view.descendant(nameTraits: ["ViewHost", name])
            guard let view = viewHost?.subviews.compactMap({ $0 as? V.NSViewType }).first else {
                throw InspectionError.viewNotFound(parent: name)
            }
            return view
    }
    
    static func lookup<V>(_ viewController: V.Type) throws -> V.NSViewControllerType
        where V: NSViewControllerRepresentable {
            let name = Inspector.typeName(type: viewController)
            let hostVC = rootViewController.descendant(nameTraits: ["NSHostingController", name])
            if let vc = hostVC?.descendants.compactMap({ $0 as? V.NSViewControllerType }).first {
                return vc
            }
            let viewHost = rootViewController.view.descendant(nameTraits: ["ViewHost"])
            guard let vc = viewHost?.subviews
                .compactMap({ $0.nextResponder as? V.NSViewControllerType }).first
            else { throw InspectionError.viewNotFound(parent: name) }
            return vc
    }
    #elseif os(iOS) || os(tvOS) || os(visionOS)
    static func lookup<V>(_ view: V.Type) throws -> V.UIViewType
        where V: UIViewRepresentable {
            let name = Inspector.typeName(type: view)
            let viewHost = window.descendant(nameTraits: ["ViewHost", name])
            guard let view = viewHost?.subviews.compactMap({ $0 as? V.UIViewType }).first else {
                throw InspectionError.viewNotFound(parent: name)
            }
            return view
    }
    
    static func lookup<V>(_ viewController: V.Type) throws -> V.UIViewControllerType
        where V: UIViewControllerRepresentable {
            let name = Inspector.typeName(type: viewController)
            let hostVC = window.rootViewController?.descendant(nameTraits: ["UIHostingController", name])
            guard let vc = hostVC?.descendants.compactMap({ $0 as? V.UIViewControllerType })
                .first else { throw InspectionError.viewNotFound(parent: name) }
            return vc
    }
    #elseif os(watchOS)
    static func lookup<V>(_ view: V.Type) throws -> V.WKInterfaceObjectType
        where V: WKInterfaceObjectRepresentable {
            let name = Inspector.typeName(type: view)
            guard let rootVC = rootInterfaceController else {
                throw InspectionError.viewNotFound(parent: name)
            }
            let host = try? Inspector.attribute(path: "super|_hostingController|some|host|_base", value: rootVC)
                ?? (try? Inspector.attribute(path: "super|$__lazy_storage_$_hostingController|some|host", value: rootVC))
            let viewCacheMapPath: String, viewProviderPath: String
            if #available(watchOS 26, *) {
                viewCacheMapPath = "some|viewGraph|renderer|renderer|some|viewCache|map"
                viewProviderPath = "container|super|coreRepresentedViewProvider"
            } else {
                viewCacheMapPath = "some|renderer|renderer|some|viewCache|map"
                viewProviderPath = "view|representedViewProvider"
            }
            guard let viewCache = try? Inspector.attribute(path: viewCacheMapPath, value: host, type: ArrayConvertible.self).allValues(),
                  let object = viewCache.compactMap({ value in
                      try? Inspector.attribute(
                        path: viewProviderPath,
                        value: value, type: V.WKInterfaceObjectType.self)
                  }).first
            else {
                throw InspectionError.viewNotFound(parent: name)
            }
            return object
    }
    #endif
}

#if os(watchOS)
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 7.0, *)
internal protocol ArrayConvertible {
    func allValues() -> [Any]
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 7.0, *)
extension Dictionary: ArrayConvertible {
    func allValues() -> [Any] { Array(values) as [Any] }
}
#endif

#if os(macOS)
@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private extension NSView {
    func descendant(nameTraits: [String]) -> NSView? {
        let name = Inspector.typeName(value: self)
        if !nameTraits.contains(where: { !name.contains($0) }) {
            return self
        }
        return subviews.lazy
            .compactMap { $0.descendant(nameTraits: nameTraits) }
            .first
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private extension NSViewController {
    func descendant(nameTraits: [String]) -> NSViewController? {
        let name = Inspector.typeName(value: self)
        if !nameTraits.contains(where: { !name.contains($0) }) {
            return self
        }
        return descendants.lazy
            .compactMap { $0.descendant(nameTraits: nameTraits) }
            .first
    }
    
    var descendants: [NSViewController] {
        let presented = presentedViewControllers ?? []
        return presented + children
    }
}
#elseif os(iOS) || os(tvOS) || os(visionOS)
@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private extension UIView {
    func descendant(nameTraits: [String]) -> UIView? {
        let name = Inspector.typeName(value: self)
        if !nameTraits.contains(where: { !name.contains($0) }) {
            return self
        }
        return subviews.lazy
            .compactMap { $0.descendant(nameTraits: nameTraits) }
            .first
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private extension UIViewController {
    func descendant(nameTraits: [String]) -> UIViewController? {
        let name = Inspector.typeName(value: self)
        if !nameTraits.contains(where: { !name.contains($0) }) {
            return self
        }
        return descendants.lazy
            .compactMap { $0.descendant(nameTraits: nameTraits) }
            .first
    }
    
    var descendants: [UIViewController] {
        let navChildren = (self as? UINavigationController)?.viewControllers ?? []
        let tabChildren = (self as? UITabBarController)?.viewControllers ?? []
        let presented = [presentedViewController].compactMap { $0 }
        return navChildren + tabChildren + presented + children
    }
}
#endif

#if os(watchOS)
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension ViewHosting {
    private static var rootInterfaceController: WKInterfaceController? {
        if #available(watchOS 7.0, *) {
            return (WKExtension.shared().delegate != nil)
                    ? WKExtension.shared().rootInterfaceController : WKApplication.shared().rootInterfaceController
        } else {
            return WKExtension.shared().rootInterfaceController
        }
    }
    
    private static func subjectForWatchOS<T>(type: T.Type) throws -> T? {
        if let extensionDelegate = WKExtension.shared().delegate,
           let subject = try? Inspector
            .attribute(path: "fallbackDelegate|some|extension|testViewSubject",
                       value: extensionDelegate, type: type) {
            return subject
        }
        
        if #available(watchOS 7.0, *) {
            if let applicationDelegate = WKApplication.shared().delegate,
               let subject = try? Inspector
                .attribute(path: "fallbackDelegate|some|application|testViewSubject",
                           value: applicationDelegate, type: type) {
                return subject
            }
        }
        
        if let rootIC = rootInterfaceController,
           let subject = try? Inspector
            .attribute(label: "testViewSubject", value: rootIC, type: type) {
            return subject
        }
        
        return nil
    }
}
#endif
