import XCTest
import SwiftUI
@testable import ViewInspector

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class AsyncImageTests: XCTestCase {
    
    private let testURL = URL(string: "https://sample.com/image.png")!
    
    func testEnclosedView() throws {
        guard #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
        else { throw XCTSkip() }
        let sut = AsyncImage(url: testURL, content: { phase in
            switch phase {
            case .success(let image): AnyView(image)
            case .failure(let error): Text(error.localizedDescription)
            case .empty: ProgressView()
            @unknown default: EmptyView()
            }
        })
        let view = try sut.inspect().asyncImage()
        XCTAssertNoThrow(try view.contentView(.empty).progressView())
        let failure = try view.contentView(.failure(InspectionError.notSupported("Test")))
        XCTAssertEqual(try failure.text().string(), "Test")
        let image = Image("test")
        let success = try view.contentView(.success(image)).anyView().image()
        XCTAssertEqual(try success.actualImage(), image)
    }
    
    func testResetsModifiers() throws {
        guard #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
        else { throw XCTSkip() }
        let sut = AsyncImage(url: testURL, content: { _ in
            EmptyView()
        }).padding()
        let view = try sut.inspect().asyncImage().contentView(.empty)
        XCTAssertEqual(view.content.medium.viewModifiers.count, 0)
    }
    
    func testExtractionFromSingleViewContainer() throws {
        guard #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
        else { throw XCTSkip() }
        let view = Button(action: { }, label: { AsyncImage(url: testURL) })
        XCTAssertNoThrow(try view.inspect().button().labelView().asyncImage())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        guard #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
        else { throw XCTSkip() }
        let view = HStack {
            AsyncImage(url: testURL)
            AsyncImage(url: testURL)
        }
        XCTAssertNoThrow(try view.inspect().hStack().asyncImage(0))
        XCTAssertNoThrow(try view.inspect().hStack().asyncImage(1))
    }
    
    func testSearch() throws {
        guard #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
        else { throw XCTSkip() }
        let sut = try AnyView(AsyncImage(url: testURL, content: { phase in
            switch phase {
            case .success(let image): AnyView(image)
            case .failure(let error): Text(error.localizedDescription)
            case .empty: ProgressView()
            @unknown default: EmptyView()
            }
        })).inspect()
        XCTAssertEqual(try sut.find(ViewType.Image.self).pathToRoot,
            "anyView().asyncImage().contentView(.success()).anyView().image()")
        XCTAssertEqual(try sut.find(ViewType.Text.self).pathToRoot,
            "anyView().asyncImage().contentView(.failure()).text()")
        XCTAssertEqual(try sut.find(ViewType.ProgressView.self).pathToRoot,
            "anyView().asyncImage().contentView(.empty).progressView()")
    }
    
    func testURLExtraction() throws {
        guard #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
        else { throw XCTSkip() }
        let sut = try AsyncImage(url: testURL).inspect().asyncImage()
        XCTAssertEqual(try sut.url(), testURL)
    }
    
    func testScale() throws {
        guard #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
        else { throw XCTSkip() }
        let sut = try AsyncImage(url: testURL, scale: 0.3).inspect().asyncImage()
        XCTAssertEqual(try sut.scale(), 0.3)
    }
    
    func testTransaction() throws {
        guard #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
        else { throw XCTSkip() }
        var transaction = Transaction()
        transaction.disablesAnimations = true
        transaction.isContinuous = true
        let sut = try AsyncImage(url: testURL, transaction: transaction, content: { _ in EmptyView() })
            .inspect().asyncImage()
        let value = try sut.transaction()
        XCTAssertEqual(value.disablesAnimations, transaction.disablesAnimations)
        XCTAssertEqual(value.isContinuous, transaction.isContinuous)
    }
}
