import SwiftUI

@main
struct watchOSApp: App {
    
    @WKExtensionDelegateAdaptor(ExtensionDelegate.self) var extDelegate
    
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
