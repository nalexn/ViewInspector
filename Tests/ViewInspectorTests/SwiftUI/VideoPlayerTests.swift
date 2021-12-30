import XCTest
import SwiftUI
import AVKit
@testable import ViewInspector

#if !os(watchOS)
@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class VideoPlayerTests: XCTestCase {
    
    private let player = AVPlayer(url: URL(string: "https://sample.com/test.mp4")!)
    
    func testEnclosedView() throws {
        guard #available(iOS 14.0, macOS 11.0, watchOS 7.0, tvOS 14.0, *)
        else { throw XCTSkip() }
        let sut = VideoPlayer(player: player, videoOverlay: {
            Text("Test")
        })
        let text = try sut.inspect().videoPlayer().videoOverlay().text()
        XCTAssertEqual(try text.string(), "Test")
    }
    
    func testResetsModifiers() throws {
        guard #available(iOS 14.0, macOS 11.0, watchOS 7.0, tvOS 14.0, *)
        else { throw XCTSkip() }
        let sut = VideoPlayer(player: player, videoOverlay: {
            EmptyView()
        }).padding()
        let view = try sut.inspect().videoPlayer().videoOverlay()
        XCTAssertEqual(view.content.medium.viewModifiers.count, 0)
    }
    
    func testExtractionFromSingleViewContainer() throws {
        guard #available(iOS 14.0, macOS 11.0, watchOS 7.0, tvOS 14.0, *)
        else { throw XCTSkip() }
        let view = Button(action: { }, label: {
            VideoPlayer(player: player)
        })
        XCTAssertNoThrow(try view.inspect().button().labelView().videoPlayer())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        guard #available(iOS 14.0, macOS 11.0, watchOS 7.0, tvOS 14.0, *)
        else { throw XCTSkip() }
        let view = HStack {
            VideoPlayer(player: player)
            VideoPlayer(player: player)
        }
        XCTAssertNoThrow(try view.inspect().hStack().videoPlayer(0))
        XCTAssertNoThrow(try view.inspect().hStack().videoPlayer(1))
    }
    
    func testSearch() throws {
        guard #available(iOS 14.0, macOS 11.0, watchOS 7.0, tvOS 14.0, *)
        else { throw XCTSkip() }
        let sut = try AnyView(VideoPlayer(player: player, videoOverlay: {
            EmptyView()
        })).inspect()
        XCTAssertEqual(try sut.find(ViewType.EmptyView.self).pathToRoot,
            "anyView().videoPlayer().videoOverlay().emptyView()")
    }
    
    func testPlayerExtraction() throws {
        guard #available(iOS 14.0, macOS 11.0, watchOS 7.0, tvOS 14.0, *)
        else { throw XCTSkip() }
        let sut1 = VideoPlayer(player: player)
        let value = try sut1.inspect().videoPlayer().player()
        XCTAssertEqual(player, value)
        let sut2 = VideoPlayer(player: nil)
        XCTAssertNil(try sut2.inspect().videoPlayer().player())
    }
}
#endif
