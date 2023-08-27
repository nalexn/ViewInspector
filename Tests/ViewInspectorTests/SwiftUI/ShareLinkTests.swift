import XCTest
import SwiftUI
@testable import ViewInspector

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
@available(tvOS, unavailable)
final class ShareLinkTests: XCTestCase {
    
    func testExtractionFromSingleViewContainer() throws {
        guard #available(iOS 16.0, tvOS 16.0, macOS 13.0, watchOS 9.0, *)
        else { throw XCTSkip() }
        let view = ShareLink(item: "Share")
        XCTAssertNoThrow(try view.inspect().shareLink())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        guard #available(iOS 16.0, tvOS 16.0, macOS 13.0, watchOS 9.0, *)
        else { throw XCTSkip() }
        let view = HStack {
            ShareLink(item: "1")
            ShareLink(item: "2")
        }
        XCTAssertNoThrow(try view.inspect().hStack().shareLink(0))
        XCTAssertNoThrow(try view.inspect().hStack().shareLink(1))
    }
    
    func testLabelView() throws {
        guard #available(iOS 16.0, tvOS 16.0, macOS 13.0, watchOS 9.0, *)
        else { throw XCTSkip() }
        let view = ShareLink("Title", item: "Item")
        let sut = try view.inspect().shareLink().labelView().text().string()
        XCTAssertEqual(sut, "Title")
    }
    
    func testSubjectView() throws {
        guard #available(iOS 16.0, tvOS 16.0, macOS 13.0, watchOS 9.0, *)
        else { throw XCTSkip() }
        let view = ShareLink("Title", item: "Item", subject: Text("Sub"))
        let sut = try view.inspect().shareLink().subjectView().string()
        XCTAssertEqual(sut, "Sub")
    }
    
    func testMessageView() throws {
        guard #available(iOS 16.0, tvOS 16.0, macOS 13.0, watchOS 9.0, *)
        else { throw XCTSkip() }
        let view = ShareLink("Title", item: "Item", message: Text("Message"))
        let sut = try view.inspect().shareLink().messageView().string()
        XCTAssertEqual(sut, "Message")
    }
    
    func testSearch() throws {
        guard #available(iOS 16.0, tvOS 16.0, macOS 13.0, watchOS 9.0, *)
        else { throw XCTSkip() }
        let viewNoSub = AnyView(ShareLink("Title", item: "Item", message: Text("Message")))
        let viewNoMessage = AnyView(ShareLink(item: "Item", subject: Text("Sub"), label: { HStack { Text("Title") } }))
        XCTAssertEqual(try viewNoSub.inspect().find(text: "Title").pathToRoot,
                       "anyView().shareLink().labelView().text()")
        XCTAssertEqual(try viewNoSub.inspect().find(text: "Message").pathToRoot,
                       "anyView().shareLink().messageView()")
        XCTAssertEqual(try viewNoMessage.inspect().find(text: "Title").pathToRoot,
                       "anyView().shareLink().labelView().hStack().text(0)")
        XCTAssertEqual(try viewNoMessage.inspect().find(text: "Sub").pathToRoot,
                       "anyView().shareLink().subjectView()")
    }
    
    func testItemsInspection() throws {
        guard #available(iOS 16.0, tvOS 16.0, macOS 13.0, watchOS 9.0, *)
        else { throw XCTSkip() }
        let view1 = ShareLink(item: "Item")
        let urls = [URL(fileURLWithPath: "1"), URL(fileURLWithPath: "2")]
        let view2 = ShareLink(items: urls)
        XCTAssertEqual(try view1.inspect().shareLink().item(type: String.self),
                       "Item")
        let urls2 = try view2.inspect().shareLink().items() as? [URL]
        XCTAssertEqual(urls2, urls)
        XCTAssertThrows(try view1.inspect().shareLink().item(type: URL.self),
                        "Type mismatch: String is not URL")
        XCTAssertThrows(try view2.inspect().shareLink().item(type: String.self),
                        "ShareLink has multiple items. Please use items() instead of item(type:)")
    }
    
    func testSharePreviewInspection() throws {
        guard #available(iOS 16.0, tvOS 16.0, macOS 13.0, watchOS 9.0, *)
        else { throw XCTSkip() }
        let sut = ShareLink(item: "Item", preview: SharePreview("1", image: "2", icon: "3"))
        let preview = try sut.inspect().shareLink()
            .sharePreview(for: "Item", imageType: String.self, iconType: String.self)
        XCTAssertEqual(try preview.image(), "2")
        XCTAssertEqual(try preview.icon(), "3")
    }
    
    func testSharePreviewMethods() throws {
        guard #available(iOS 16.0, tvOS 16.0, macOS 13.0, watchOS 9.0, *)
        else { throw XCTSkip() }
        let url = URL(fileURLWithPath: "1")
        let sut = SharePreview("Title", image: url, icon: "icon")
        XCTAssertEqual(try sut.title().string(), "Title")
        XCTAssertEqual(try sut.image(), url)
        XCTAssertEqual(try sut.icon(), "icon")
    }
}
