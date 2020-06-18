import XCTest
import SwiftUI
@testable import ViewInspector

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class RadialGradientTests: XCTestCase {
    
    let gradient = Gradient(colors: [.red])
    
    func testInspect() throws {
        let sut = RadialGradient(gradient: gradient, center: .top, startRadius: 0, endRadius: 1)
        XCTAssertNoThrow(try sut.inspect())
    }
    
    func testExtractionFromSingleViewContainer() throws {
        let view = AnyView(RadialGradient(gradient: gradient, center: .top, startRadius: 0, endRadius: 1))
        XCTAssertNoThrow(try view.inspect().anyView().radialGradient())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let view = HStack {
            RadialGradient(gradient: gradient, center: .top, startRadius: 0, endRadius: 1)
            RadialGradient(gradient: gradient, center: .top, startRadius: 0, endRadius: 1)
        }
        XCTAssertNoThrow(try view.inspect().hStack().radialGradient(0))
        XCTAssertNoThrow(try view.inspect().hStack().radialGradient(1))
    }
    
    func testGradient() throws {
        let sut = try RadialGradient(gradient: gradient, center: .top, startRadius: 0, endRadius: 1)
            .inspect().radialGradient().gradient()
        XCTAssertEqual(sut, gradient)
    }
    
    func testCenter() throws {
        let center: UnitPoint = .topLeading
        let sut = try RadialGradient(gradient: gradient, center: center, startRadius: 0, endRadius: 1)
            .inspect().radialGradient().center()
        XCTAssertEqual(sut, center)
    }
    
    func testStartRadius() throws {
        let radius: CGFloat = 0.5
        let sut = try RadialGradient(gradient: gradient, center: .center,
                                     startRadius: radius, endRadius: 1)
            .inspect().radialGradient().startRadius()
        XCTAssertEqual(sut, radius)
    }
    
    func testEndRadius() throws {
        let radius: CGFloat = 0.5
        let sut = try RadialGradient(gradient: gradient, center: .center,
                                     startRadius: 0, endRadius: radius)
            .inspect().radialGradient().endRadius()
        XCTAssertEqual(sut, radius)
    }
}
