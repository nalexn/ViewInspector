import XCTest
import SwiftUI
@testable import ViewInspector

#if os(iOS) || os(tvOS)
@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class CustomInspectableTests: XCTestCase {

    func testCustomInspectableViewRepresentable() throws {
        let sut = CustomViewRepresentable(labels: ["1", "abc"])
        XCTAssertNoThrow(try sut.inspect().find(text: "abc"))
    }

}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct CustomViewRepresentable: UIViewRepresentable, CustomInspectable {

    let labels: [String]

    @ViewBuilder
    var customInspectableContent: some View {
        let indexedLabels = Array(labels.enumerated())
        ForEach(indexedLabels, id: \.0) { _, label in
            Text(label)
        }
    }

    func makeUIView(context: Context) -> UIView {
        // This could be a UICollectionView, a UIStackView, or a custom view with some hosted
        // SwiftUI views (via `UIHostingController`)
        UIView()
    }

    func updateUIView(_ view: UIView, context: Context) { }
}
#endif
