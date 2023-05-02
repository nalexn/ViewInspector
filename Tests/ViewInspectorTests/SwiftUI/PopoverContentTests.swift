import Foundation
import SwiftUI
import ViewInspector
import XCTest

#if os(macOS)
import AppKit

private protocol AnyHostingView {
    var anyRootView: AnyView { get }
}

extension NSHostingView: AnyHostingView {
    fileprivate var anyRootView: AnyView { AnyView(rootView) }
}

private class TestModel: ObservableObject {
    @Published var showPopover = false
}

private struct WindowRootView: View {
    @ObservedObject var model: TestModel

    var body: some View {
        Rectangle()
            .foregroundColor(.red)
            .popover(isPresented: $model.showPopover) {
                Text("popover content")
                    .padding()
            }
    }
}

class PopoverContentTests: XCTestCase {

    private var window: NSWindow! = NSWindow(
        contentRect: .init(x: 0, y: 0, width: 200, height: 200),
        styleMask: [.titled, .resizable, .miniaturizable, .closable],
        backing: .buffered,
        defer: false
    )

    private let model = TestModel()

    override func tearDown() {
        window.orderOut(nil)
    }

    func testPopoverContent() throws {
        window.contentView = NSHostingView(rootView: WindowRootView(model: model))
        window.orderBack(nil)
        model.showPopover = true
        CATransaction.commit()

        let maybePopoverContentView = window
            .childWindows?
            .first { $0.accessibilityParent() as? NSView === window.contentView }?
            .contentView

        let popoverContentView = try XCTUnwrap(maybePopoverContentView as? AnyHostingView)
        let popoverRootView = try popoverContentView.anyRootView.inspect()
        XCTAssertNoThrow(try popoverRootView.find(text: "popover content"))
    }
}

#endif
