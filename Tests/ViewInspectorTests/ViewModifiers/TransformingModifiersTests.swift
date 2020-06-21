import XCTest
import SwiftUI
@testable import ViewInspector

// MARK: - ViewTransformingTests

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class ViewTransformingTests: XCTestCase {
    
    func testRotationEffect() throws {
        let sut = EmptyView().rotationEffect(.degrees(5), anchor: .center)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testRotation3DEffect() throws {
        let sut = EmptyView().rotation3DEffect(.degrees(5), axis: (5, 5, 5),
                                               anchor: .center, anchorZ: 5, perspective: 5)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testProjectionEffect() throws {
        let sut = EmptyView().projectionEffect(ProjectionTransform())
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testTransformEffect() throws {
        let sut = EmptyView().transformEffect(.identity)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
}

// MARK: - ViewScalingTests

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class ViewScalingTests: XCTestCase {
    
    func testScaledToFill() throws {
        let sut = EmptyView().scaledToFill()
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testScaledToFillInspection() throws {
        let sut1 = EmptyView().scaledToFill()
        let sut2 = EmptyView().scaledToFit()
        let sut3 = EmptyView().aspectRatio(contentMode: .fill)
        XCTAssertTrue(try sut1.inspect().isScaledToFill())
        XCTAssertFalse(try sut2.inspect().isScaledToFill())
        XCTAssertTrue(try sut3.inspect().isScaledToFill())
    }
    
    func testScaledToFit() throws {
        let sut = EmptyView().scaledToFit()
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testScaledToFitlInspection() throws {
        let sut1 = EmptyView().scaledToFit()
        let sut2 = EmptyView().scaledToFill()
        let sut3 = EmptyView().aspectRatio(contentMode: .fit)
        XCTAssertTrue(try sut1.inspect().isScaledToFit())
        XCTAssertFalse(try sut2.inspect().isScaledToFit())
        XCTAssertTrue(try sut3.inspect().isScaledToFit())
    }
    
    func testScaleEffectFloat() throws {
        let sut = EmptyView().scaleEffect(5, anchor: .leading)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testScaleEffectSize() throws {
        let sut = EmptyView().scaleEffect(CGSize(width: 5, height: 5), anchor: .leading)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testScaleEffectXY() throws {
        let sut = EmptyView().scaleEffect(x: 5, y: 5, anchor: .center)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testScaleEffectInspection() throws {
        let sut = EmptyView().scaleEffect(5, anchor: .leading)
        XCTAssertEqual(try sut.inspect().emptyView().scaleEffect(), CGSize(width: 5, height: 5))
    }
    
    func testScaleEffectAnchorInspection() throws {
        let sut = EmptyView().scaleEffect(5, anchor: .leading)
        XCTAssertEqual(try sut.inspect().emptyView().scaleEffectAnchor(), .leading)
    }
    
    func testAspectRatioContentModeInspection() throws {
        let sut = EmptyView().aspectRatio(5, contentMode: .fit)
        XCTAssertEqual(try sut.inspect().emptyView().aspectRatioContentMode(), .fit)
    }
    
    func testAspectRatioFloat() throws {
        let sut = EmptyView().aspectRatio(5, contentMode: .fill)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testAspectRatioFloatInspection() throws {
        let sut = EmptyView().aspectRatio(5, contentMode: .fill)
        XCTAssertEqual(try sut.inspect().emptyView().aspectRatio(), 5)
    }
    
    func testAspectRatioSize() throws {
        let sut = EmptyView().aspectRatio(CGSize(width: 5, height: 6), contentMode: .fit)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testAspectRatioSizeInspection() throws {
        let sut = EmptyView().aspectRatio(CGSize(width: 3, height: 4), contentMode: .fit)
        XCTAssertEqual(try sut.inspect().emptyView().aspectRatio(), 0.75)
    }
    
    #if !os(macOS)
    func testImageScale() throws {
        let sut = EmptyView().imageScale(.small)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testImageScaleInspection() throws {
        let sut = EmptyView().imageScale(.small)
        XCTAssertEqual(try sut.inspect().emptyView().imageScale(), .small)
    }
    #endif
}
