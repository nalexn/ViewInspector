import XCTest
import SwiftUI
@testable import ViewInspector

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class EllipticalGradientTests: XCTestCase {

    let gradient = Gradient(colors: [.red])

    func testInspect() throws {
        guard #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
        else { throw XCTSkip() }
        let sut = EllipticalGradient(gradient: gradient, center: .center)
        XCTAssertNoThrow(try sut.inspect())
    }

    func testExtractionFromSingleViewContainer() throws {
        guard #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
        else { throw XCTSkip() }
        let view = AnyView(EllipticalGradient(gradient: gradient, center: .center))
        XCTAssertNoThrow(try view.inspect().anyView().ellipticalGradient())
    }

    func testExtractionFromMultipleViewContainer() throws {
        guard #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
        else { throw XCTSkip() }
        let view = HStack {
            EllipticalGradient(gradient: gradient, center: .center)
            EllipticalGradient(gradient: gradient, center: .center)
        }
        XCTAssertNoThrow(try view.inspect().hStack().ellipticalGradient(0))
        XCTAssertNoThrow(try view.inspect().hStack().ellipticalGradient(1))
    }

    func testSearch() throws {
        guard #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
        else { throw XCTSkip() }
        let view = AnyView(EllipticalGradient(gradient: gradient, center: .center))
        XCTAssertEqual(try view.inspect().find(ViewType.EllipticalGradient.self).pathToRoot,
                       "anyView().ellipticalGradient()")
    }

    func testGradient() throws {
        guard #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
        else { throw XCTSkip() }
        let sut = try EllipticalGradient(gradient: gradient, center: .center)
            .inspect().ellipticalGradient().gradient()
        XCTAssertEqual(sut, gradient)
    }

    func testCenter() throws {
        guard #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
        else { throw XCTSkip() }
        let center: UnitPoint = .topLeading
        let sut = try EllipticalGradient(gradient: gradient, center: center)
            .inspect().ellipticalGradient().center()
        XCTAssertEqual(sut, center)
    }

    func testStartRadiusFraction() throws {
        guard #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
        else { throw XCTSkip() }
        let radius: CGFloat = 0.5
        let sut = try EllipticalGradient(gradient: gradient, center: .center,
                                         startRadiusFraction: radius, endRadiusFraction: 1.0)
            .inspect().ellipticalGradient().startRadiusFraction()
        XCTAssertEqual(sut, radius)
    }

    func testEndAngle() throws {
        guard #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
        else { throw XCTSkip() }
        let radius: CGFloat = 0.5
        let sut = try EllipticalGradient(gradient: gradient, center: .center,
                                         startRadiusFraction: 0.0, endRadiusFraction: radius)
            .inspect().ellipticalGradient().endRadiusFraction()
        XCTAssertEqual(sut, radius)
    }
}
