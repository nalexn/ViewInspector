import XCTest
import SwiftUI
@testable import ViewInspector

final class AngularGradientTests: XCTestCase {
    
    let gradient = Gradient(colors: [.red])
    
    func testInspect() throws {
        let sut = AngularGradient(gradient: gradient, center: .center)
        XCTAssertNoThrow(try sut.inspect())
    }
    
    func testExtractionFromSingleViewContainer() throws {
        let view = AnyView(AngularGradient(gradient: gradient, center: .center))
        XCTAssertNoThrow(try view.inspect().angularGradient())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let view = HStack {
            AngularGradient(gradient: gradient, center: .center)
            AngularGradient(gradient: gradient, center: .center)
        }
        XCTAssertNoThrow(try view.inspect().angularGradient(0))
        XCTAssertNoThrow(try view.inspect().angularGradient(1))
    }
    
    func testGradient() throws {
        let sut = try AngularGradient(gradient: gradient, center: .center)
            .inspect().gradient()
        XCTAssertEqual(sut, gradient)
    }
    
    func testCenter() throws {
        let center: UnitPoint = .topLeading
        let sut = try AngularGradient(gradient: gradient, center: center)
            .inspect().center()
        XCTAssertEqual(sut, center)
    }
    
    func testStartAngle() throws {
        let angle = Angle(degrees: 123)
        let sut = try AngularGradient(gradient: gradient, center: .center,
                                      startAngle: angle, endAngle: Angle())
            .inspect().startAngle()
        XCTAssertEqual(sut, angle)
    }
    
    func testEndAngle() throws {
        let angle = Angle(degrees: 123)
        let sut = try AngularGradient(gradient: gradient, center: .center,
                                      startAngle: Angle(), endAngle: angle)
            .inspect().endAngle()
        XCTAssertEqual(sut, angle)
    }
}
