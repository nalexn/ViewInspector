import XCTest
import SwiftUI
@testable import ViewInspector

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class AngularGradientTests: XCTestCase {
    
    let gradient = Gradient(colors: [.red])
    
    func testInspect() throws {
        let sut = AngularGradient(gradient: gradient, center: .center)
        XCTAssertNoThrow(try sut.inspect())
    }
    
    func testExtractionFromSingleViewContainer() throws {
        let view = AnyView(AngularGradient(gradient: gradient, center: .center))
        XCTAssertNoThrow(try view.inspect().anyView().angularGradient())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let view = HStack {
            AngularGradient(gradient: gradient, center: .center)
            AngularGradient(gradient: gradient, center: .center)
        }
        XCTAssertNoThrow(try view.inspect().hStack().angularGradient(0))
        XCTAssertNoThrow(try view.inspect().hStack().angularGradient(1))
    }
    
    func testSearch() throws {
        let view = AnyView(AngularGradient(gradient: gradient, center: .center))
        XCTAssertEqual(try view.inspect().find(ViewType.AngularGradient.self).pathToRoot,
                       "anyView().angularGradient()")
    }
    
    func testGradient() throws {
        let sut = try AngularGradient(gradient: gradient, center: .center)
            .inspect().angularGradient().gradient()
        XCTAssertEqual(sut, gradient)
    }
    
    func testCenter() throws {
        let center: UnitPoint = .topLeading
        let sut = try AngularGradient(gradient: gradient, center: center)
            .inspect().angularGradient().center()
        XCTAssertEqual(sut, center)
    }
    
    func testStartAngle() throws {
        let angle = Angle(degrees: 123)
        let sut = try AngularGradient(gradient: gradient, center: .center,
                                      startAngle: angle, endAngle: Angle())
            .inspect().angularGradient().startAngle()
        XCTAssertEqual(sut, angle)
    }
    
    func testEndAngle() throws {
        let angle = Angle(degrees: 123)
        let sut = try AngularGradient(gradient: gradient, center: .center,
                                      startAngle: Angle(), endAngle: angle)
            .inspect().angularGradient().endAngle()
        XCTAssertEqual(sut, angle)
    }
}
