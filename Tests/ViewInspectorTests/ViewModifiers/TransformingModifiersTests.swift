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
    
    func testScaledToFit() throws {
        let sut = EmptyView().scaledToFit()
        XCTAssertNoThrow(try sut.inspect().emptyView())
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
    
    func testAspectRatioFloat() throws {
        let sut = EmptyView().aspectRatio(5, contentMode: .fill)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testAspectRatioSize() throws {
        let sut = EmptyView().aspectRatio(CGSize(width: 5, height: 5), contentMode: .fit)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    #if !os(macOS)
    func testImageScale() throws {
        let sut = EmptyView().imageScale(.small)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    #endif
}
