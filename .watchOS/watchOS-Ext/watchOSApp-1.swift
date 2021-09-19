import SwiftUI

@main
struct watchOSApp: App {
    
    // swiftlint:disable weak_delegate
    @WKExtensionDelegateAdaptor(ExtensionDelegate.self) var extDelegate
    // swiftlint:enable weak_delegate
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                Text("Hi")
            }
            .testable(extDelegate.testViewSubject)
        }
    }
}

final class ExtensionDelegate: NSObject, WKExtensionDelegate {
    let testViewSubject = TestViewSubject([])
}
