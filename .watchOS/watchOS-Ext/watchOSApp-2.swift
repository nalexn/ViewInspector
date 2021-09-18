import WatchKit
import SwiftUI

final class RootInterfaceController: WKHostingController<RootView<ContentView>> {
    
    let testViewSubject = TestViewSubject([])
    
    override var body: RootView<ContentView> {
        return ContentView()
            .testable(testViewSubject)
    }
}

struct ContentView: View {
    var body: some View {
        Text("Hi")
    }
}

final class ExtensionDelegate: NSObject, WKExtensionDelegate {

}
