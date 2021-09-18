import SwiftUI
import WatchKit
import Combine

typealias TestViewSubject = CurrentValueSubject<[(String, AnyView)], Never>

#if !(os(watchOS) && DEBUG)

typealias RootView<T> = T

extension View {
    @inline(__always)
    func testable(_ injector: TestViewSubject) -> Self {
        self
    }
}

#else

typealias RootView<T> = ModifiedContent<T, TestViewHost>

extension View {
    func testable(_ injector: TestViewSubject) -> ModifiedContent<Self, TestViewHost> {
        modifier(TestViewHost(injector: injector))
    }
}

struct TestViewHost: ViewModifier {
    
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

#endif
