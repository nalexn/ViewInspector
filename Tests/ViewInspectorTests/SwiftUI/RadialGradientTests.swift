import XCTest
import SwiftUI
@testable import ViewInspector

final class RadialGradientTests: XCTestCase {
    
    let gradient = Gradient(colors: [.red])
    
    func testInspect() throws {
        let sut = RadialGradient(gradient: gradient, center: .top, startRadius: 0, endRadius: 1)
        XCTAssertNoThrow(try sut.inspect())
    }
    
    func testExtractionFromSingleViewContainer() throws {
        let view = AnyView(RadialGradient(gradient: gradient, center: .top, startRadius: 0, endRadius: 1))
        XCTAssertNoThrow(try view.inspect().radialGradient())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let view = HStack {
            RadialGradient(gradient: gradient, center: .top, startRadius: 0, endRadius: 1)
            RadialGradient(gradient: gradient, center: .top, startRadius: 0, endRadius: 1)
        }
        XCTAssertNoThrow(try view.inspect().radialGradient(0))
        XCTAssertNoThrow(try view.inspect().radialGradient(1))
    }
    
    func testGradient() throws {
        let sut = try RadialGradient(gradient: gradient, center: .top, startRadius: 0, endRadius: 1)
            .inspect().gradient()
        XCTAssertEqual(sut, gradient)
    }
    
    func testCenter() throws {
        let center: UnitPoint = .topLeading
        let sut = try RadialGradient(gradient: gradient, center: center, startRadius: 0, endRadius: 1)
            .inspect().center()
        XCTAssertEqual(sut, center)
    }
    
    func startRadius() throws {
        let radius: CGFloat = 0.5
        let sut = try RadialGradient(gradient: gradient, center: .center,
                                     startRadius: radius, endRadius: 1)
            .inspect().startRadius()
        XCTAssertEqual(sut, radius)
    }
    
    func engRadius() throws {
        let radius: CGFloat = 0.5
        let sut = try RadialGradient(gradient: gradient, center: .center,
                                     startRadius: 0, endRadius: radius)
            .inspect().startRadius()
        XCTAssertEqual(sut, radius)
    }
}
