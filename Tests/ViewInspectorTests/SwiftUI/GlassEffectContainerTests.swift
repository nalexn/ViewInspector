#if !os(visionOS)

import XCTest
import SwiftUI
@testable import ViewInspector

@MainActor
@available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, *)
final class GlassEffectContainerTests: XCTestCase {

    // MARK: - GlassEffectContainer Tests

    func testExtractionFromSingleViewContainer() throws {
        let view = AnyView(GlassEffectContainer { Text("Test") })
        XCTAssertNoThrow(try view.inspect().anyView().glassEffectContainer())
    }

    func testExtractionFromMultipleViewContainer() throws {
        let view = HStack {
            GlassEffectContainer { Text("First") }
            GlassEffectContainer { Text("Second") }
        }
        XCTAssertNoThrow(try view.inspect().hStack().glassEffectContainer(0))
        XCTAssertNoThrow(try view.inspect().hStack().glassEffectContainer(1))
    }

    func testContentExtraction() throws {
        let sut = GlassEffectContainer {
            Text("Hello")
            Text("World")
        }
        let content = try sut.inspect().glassEffectContainer()
        XCTAssertEqual(content.count, 2)
        XCTAssertEqual(try content.text(0).string(), "Hello")
        XCTAssertEqual(try content.text(1).string(), "World")
    }

    func testSpacingCustom() throws {
        let sut = GlassEffectContainer(spacing: 20) {
            Text("Test")
        }
        let spacing = try sut.inspect().glassEffectContainer().spacing()
        XCTAssertEqual(spacing, 20.0)
    }

    func testSearchForChildInsideGlassEffectContainer() throws {
        let view = VStack {
            Text("Before")
            GlassEffectContainer {
                Text("Child1")
                Text("Child2")
            }
            Text("After")
        }
        XCTAssertEqual(
            try view.inspect().find(text: "Child2").pathToRoot,
            "vStack().glassEffectContainer(1).text(1)")
    }

    // MARK: - glassEffect Modifier Tests

    func testGlassEffectModifier() throws {
        let sut = Text("Test").glassEffect()
        XCTAssertNoThrow(try sut.inspect().text().glassEffect())
    }

    func testGlassEffectTintColorNil() throws {
        let sut = Text("Test").glassEffect()
        let glass = try sut.inspect().text().glassEffect()
        XCTAssertNil(try glass.tintColor())
    }

    func testGlassEffectTintColorRed() throws {
        let sut = Text("Test").glassEffect(.regular.tint(.red))
        let glass = try sut.inspect().text().glassEffect()
        XCTAssertEqual(try glass.tintColor(), .red)
    }

    func testGlassEffectShape() throws {
        let sut = Text("Test").glassEffect(in: RoundedRectangle(cornerRadius: 10))
        let glass = try sut.inspect().text().glassEffect()
        let shape = try glass.shape(RoundedRectangle.self)
        XCTAssertEqual(shape.cornerSize.width, 10)
        XCTAssertEqual(shape.cornerSize.height, 10)
    }

    // MARK: - glassEffectTransition Modifier Tests

    func testGlassEffectTransitionMaterialize() throws {
        let sut = Text("Test").glassEffectTransition(.materialize)
        let transition = try sut.inspect().text().glassEffectTransition()
        XCTAssertEqual(transition, .materialize)
    }

    func testGlassEffectTransitionMatchedGeometry() throws {
        let sut = Text("Test").glassEffectTransition(.matchedGeometry)
        let transition = try sut.inspect().text().glassEffectTransition()
        XCTAssertEqual(transition, .matchedGeometry)
    }

    func testGlassEffectTransitionIdentity() throws {
        let sut = Text("Test").glassEffectTransition(.identity)
        let transition = try sut.inspect().text().glassEffectTransition()
        XCTAssertEqual(transition, .identity)
    }

    // MARK: - glassEffectID Modifier Tests

    @Namespace var ns

    func testGlassEffectID() throws {
        let sut = Text("Test").glassEffectID("testID", in: ns)
        let result = try sut.inspect().text().glassEffectID()
        XCTAssertEqual(result.id, AnyHashable("testID"))
        XCTAssertNotNil(result.namespace)
    }

    // MARK: - glassEffectUnion Modifier Tests

    func testGlassEffectUnion() throws {
        let sut = Text("Test").glassEffectUnion(id: "unionID", namespace: ns)
        let result = try sut.inspect().text().glassEffectUnion()
        XCTAssertEqual(result.id, AnyHashable("unionID"))
        XCTAssertNotNil(result.namespace)
    }

    // MARK: - glassEffect isInteractive Tests

    func testGlassEffectIsInteractiveDefault() throws {
        let sut = Text("Test").glassEffect()
        let glass = try sut.inspect().text().glassEffect()
        XCTAssertFalse(try glass.isInteractive())
    }

    func testGlassEffectIsInteractiveTrue() throws {
        let sut = Text("Test").glassEffect(.regular.interactive(true))
        let glass = try sut.inspect().text().glassEffect()
        XCTAssertTrue(try glass.isInteractive())
    }

    func testGlassEffectIsInteractiveFalse() throws {
        let sut = Text("Test").glassEffect(.regular.interactive(false))
        let glass = try sut.inspect().text().glassEffect()
        XCTAssertFalse(try glass.isInteractive())
    }

    // MARK: - Chained Glass Methods Tests

    func testGlassEffectChainedTintOverwrites() throws {
        // Chaining tint() calls overwrites - last one wins
        let sut = Text("Test").glassEffect(.regular.tint(.red).tint(.blue))
        let glass = try sut.inspect().text().glassEffect()
        XCTAssertEqual(try glass.tintColor(), .blue)
    }

    func testGlassEffectChainedDifferentMethods() throws {
        // Chaining different methods preserves all values
        let sut = Text("Test").glassEffect(.regular.tint(.red).interactive(true))
        let glass = try sut.inspect().text().glassEffect()
        XCTAssertEqual(try glass.tintColor(), .red)
        XCTAssertTrue(try glass.isInteractive())
    }

    func testGlassEffectChainedAllMethods() throws {
        // Chain all available methods
        let sut = Text("Test").glassEffect(
            .regular.tint(.green).interactive(true),
            in: Circle()
        )
        let glass = try sut.inspect().text().glassEffect()
        XCTAssertEqual(try glass.tintColor(), .green)
        XCTAssertTrue(try glass.isInteractive())
        XCTAssertNoThrow(try glass.shape(Circle.self))
    }

    // MARK: - Missing Modifier Error Tests

    func testGlassEffectMissingModifierError() throws {
        let sut = EmptyView().padding()
        XCTAssertThrows(
            try sut.inspect().emptyView().glassEffect(),
            "EmptyView does not have 'glassEffect' modifier")
    }

    func testGlassEffectTransitionMissingModifierError() throws {
        let sut = EmptyView().padding()
        XCTAssertThrows(
            try sut.inspect().emptyView().glassEffectTransition(),
            "EmptyView does not have 'glassEffectTransition' modifier")
    }

    func testGlassEffectIDMissingModifierError() throws {
        let sut = EmptyView().padding()
        XCTAssertThrows(
            try sut.inspect().emptyView().glassEffectID(),
            "EmptyView does not have 'glassEffectID' modifier")
    }

    func testGlassEffectUnionMissingModifierError() throws {
        let sut = EmptyView().padding()
        XCTAssertThrows(
            try sut.inspect().emptyView().glassEffectUnion(),
            "EmptyView does not have 'glassEffectUnion' modifier")
    }
}

#endif
