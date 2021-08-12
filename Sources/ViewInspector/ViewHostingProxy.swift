import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public protocol ViewHostingProxy {
    static var instance: Self { get }
    func host(view: AnyView?)
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension ViewHosting {
    private(set) internal static var proxy: ViewHostingProxy?
    
    static func register(proxy: ViewHostingProxy?) {
        self.proxy = proxy
    }
}
