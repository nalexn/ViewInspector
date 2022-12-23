import SwiftUI
import Combine
#if canImport(UIKit)
import UIKit
#endif

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct ViewHosting { }

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension ViewHosting {
    
    struct ViewId: Hashable {
        let function: String
        var key: String { function }
    }
    
    static func host<V>(view: V, size: CGSize? = nil, function: String = #function) where V: View {
        let viewId = ViewId(function: function)
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
        #if os(watchOS)
        _ = expel(viewId: viewId)
        try? watchOS(host: nil, viewId: viewId)
        #else
        guard let hosted = expel(viewId: viewId) else { return }
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
        let ext = WKExtension.shared()
        guard let subject: Subject = {
            if let delegate = ext.delegate,
               let subject = try? Inspector
                 .attribute(path: "fallbackDelegate|some|extension|testViewSubject",
                            value: delegate, type: Subject.self) {
                return subject
            }
            if let rootIC = ext.rootInterfaceController,
               let subject = try? Inspector
                 .attribute(label: "testViewSubject", value: rootIC, type: Subject.self) {
                return subject
            }
            return nil
        }() else {
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
        return hosted[viewId]?.medium ?? .empty
    }
}

// MARK: - Private

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private extension ViewHosting {
    
    struct Hosted {
        #if os(macOS)
        let viewController: NSViewController
        #elseif os(iOS) || os(tvOS)
        let viewController: UIViewController
        #endif
        let medium: Content.Medium
    }
    private static var hosted: [ViewId: Hosted] = [:]
    #if os(macOS)
    static var window: NSWindow = makeWindow()
    #elseif os(iOS) || os(tvOS)
    static var window: UIWindow = makeWindow()
    #endif
    
    // MARK: - Window construction
    
    #if os(macOS)
    static func makeWindow() -> NSWindow {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 200, height: 200),
            styleMask: [.titled, .resizable, .miniaturizable, .closable],
            backing: .buffered,
            defer: false)
        window.contentViewController = RootViewController()
        window.makeKeyAndOrderFront(window)
        window.layoutIfNeeded()
        return window
    }
    #elseif os(iOS) || os(tvOS)
    static func makeWindow() -> UIWindow {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = UIViewController()
        window.rootViewController?.view.translatesAutoresizingMaskIntoConstraints = false
        window.makeKeyAndVisible()
        window.layoutIfNeeded()
        return window
    }
    #endif
    
    // MARK: - ViewControllers
    
    #if os(macOS)
    static var rootViewController: NSViewController {
        window.contentViewController!
    }
    static func hostVC<V>(_ view: V) -> NSHostingController<V> where V: View {
        NSHostingController(rootView: view)
    }
    #elseif os(iOS) || os(tvOS)
    static var rootViewController: UIViewController {
        window.rootViewController!
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
    #elseif os(iOS) || os(tvOS)
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
    
    static func expel(viewId: ViewId) -> Hosted? {
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
    #elseif os(iOS) || os(tvOS)
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
            guard let rootVC = WKExtension.shared().rootInterfaceController,
                  let viewCache = try? Inspector.attribute(path: """
                  super|$__lazy_storage_$_hostingController|some|\
                  host|renderer|renderer|some|viewCache|map
                  """, value: rootVC, type: ArrayConvertible.self).allValues(),
                  let object = viewCache.compactMap({ value in
                      try? Inspector.attribute(
                        path: "view|representedViewProvider",
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
#elseif os(iOS) || os(tvOS)
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
