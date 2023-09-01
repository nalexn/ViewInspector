import SwiftUI

final class ExtensionDelegate: NSObject, WKExtensionDelegate {
    let testViewSubject = TestViewSubject([])
}

@main
struct watchOS_Watch_AppApp: App {
    
    @WKExtensionDelegateAdaptor(ExtensionDelegate.self) var extDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .testable(extDelegate.testViewSubject)
        }
    }
}

struct ContentView: View {
    var body: some View {
        Text("ViewInspector").padding()
    }
}
