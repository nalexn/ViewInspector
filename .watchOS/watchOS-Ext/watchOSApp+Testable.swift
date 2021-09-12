import SwiftUI
import WatchKit
import Combine

typealias TestViewSubject = CurrentValueSubject<AnyView?, Never>

#if os(watchOS) && DEBUG

extension View {
    func testable(_ injector: TestViewSubject) -> some View {
        modifier(TestViewHost(injector: injector))
    }
}

private struct TestViewHost: ViewModifier {
    
    @State private var hostedView: AnyView?
    let injector: TestViewSubject
    
    func body(content: Content) -> some View {
        Group {
            if let view = hostedView {
                view
            } else {
                content
            }
        }
        .onReceive(injector) { hostedView = $0 }
    }
}

#else

extension View {
    @inline(__always)
    func testable(_ injector: TestViewSubject) -> some View {
        self
    }
}

#endif
