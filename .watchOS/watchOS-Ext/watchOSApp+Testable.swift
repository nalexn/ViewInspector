import SwiftUI
import WatchKit
import Combine

typealias TestViewSubject = CurrentValueSubject<[(String, AnyView)], Never>

#if os(watchOS) && DEBUG

extension View {
    func testable(_ injector: TestViewSubject) -> some View {
        modifier(TestViewHost(injector: injector))
    }
}

private struct TestViewHost: ViewModifier {
    
    @State private var hostedViews: [(String, AnyView)] = []
    let injector: TestViewSubject
    
    func body(content: Content) -> some View {
        ZStack {
            content
            ForEach(hostedViews, id: \.0) { $0.1 }
        }
        .onReceive(injector) { hostedViews = $0 }
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
