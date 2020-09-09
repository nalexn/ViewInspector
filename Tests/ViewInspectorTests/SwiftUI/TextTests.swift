import XCTest
import SwiftUI
@testable import ViewInspector

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class TextTests: XCTestCase {
    
    // MARK: - string()
    
    func testLocalizableStringNoParams() throws {
        let view = Text("Test")
        let sut = try view.inspect().text().string()
        XCTAssertEqual(sut, "Test")
    }
    
    func testLocalizableStringWithOneParam() throws {
        let view = Text("Test \(12)")
        let sut = try view.inspect().text().string()
        XCTAssertEqual(sut, "Test 12")
    }
    
    func testLocalizableStringWithMultipleParams() throws {
        let view = Text("Test \(12) \(5.7) \("abc")")
        let sut = try view.inspect().text().string()
        XCTAssertEqual(sut, "Test 12 5.7 abc")
    }
    
    func testExternalStringValue() throws {
        let string = "Test"
        let view = Text(string)
        let sut = try view.inspect().text().string()
        XCTAssertEqual(sut, string)
    }
    
    func testConcatenatedTexts() throws {
        let view = Text("Test") + Text("Abc").bold() + Text("123")
        let sut = try view.inspect().text().string()
        XCTAssertEqual(sut, "TestAbc123")
    }
    
    func testExtractionFromSingleViewContainer() throws {
        let view = AnyView(Text("Test"))
        XCTAssertNoThrow(try view.inspect().anyView().text())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let view = HStack { Text("Test"); Text("Test") }
        XCTAssertNoThrow(try view.inspect().hStack().text(0))
        XCTAssertNoThrow(try view.inspect().hStack().text(1))
    }

    func testBoldAttribute() throws {
        let view1 = Text("Test")
        let sut1 = try view1.inspect().text().attributes()
        XCTAssertThrows(try sut1.isBold(), "Text does not have 'bold' modifier")
        let view2 = Text("Test").strikethrough().bold()
        let sut2 = try view2.inspect().text().attributes()
        XCTAssertTrue(try sut2.isBold())
        let view3 = Text("Test").kerning(1).bold().italic()
        let sut3 = try view3.inspect().text().attributes()
        XCTAssertTrue(try sut3.isBold())
    }
    
    func testItalicAttribute() throws {
        let view1 = Text("Test")
        let sut1 = try view1.inspect().text().attributes()
        XCTAssertThrows(try sut1.isItalic(), "Text does not have 'italic' modifier")
        let view2 = Text("Test").italic()
        let sut2 = try view2.inspect().text().attributes()
        XCTAssertTrue(try sut2.isItalic())
        let view3 = Text("Test").kerning(1).italic().bold()
        let sut3 = try view3.inspect().text().attributes()
        XCTAssertTrue(try sut3.isItalic())
    }
    
    func testFontAttribute() throws {
        let system = Font.system(size: 24, weight: .semibold, design: .monospaced)
        let view1 = Text("Test").kerning(2).font(system)
        let sut1 = try view1.inspect().text().attributes()
        XCTAssertEqual(try sut1.font(), system)
        let custom = Font.custom("Avenir-Roman", size: 15)
        let view2 = Text("Test").font(custom)
        let sut2 = try view2.inspect().text().attributes()
        XCTAssertEqual(try sut2.font(), custom)
    }

    func testFontWeightAttribute() throws {
        let view = Text("Test").italic().fontWeight(.heavy)
        let sut = try view.inspect().text().attributes()
        XCTAssertEqual(try sut.fontWeight(), .heavy)
    }
    
    func testForegroundColorAttribute() throws {
        let view = Text("Test").italic().foregroundColor(.green)
        let sut = try view.inspect().text().attributes()
        XCTAssertEqual(try sut.foregroundColor(), .green)
    }
    
    func testStrikethroughAttribute() throws {
        let view = Text("Test").bold().strikethrough(true, color: .black)
        let sut = try view.inspect().text().attributes()
        XCTAssertTrue(try sut.strikethrough())
        XCTAssertEqual(try sut.strikethroughColor(), .black)
    }
    
    func testUnderlineAttribute() throws {
        let view = Text("Test").bold().underline(true, color: .black)
        let sut = try view.inspect().text().attributes()
        XCTAssertTrue(try sut.underline())
        XCTAssertEqual(try sut.underlineColor(), .black)
    }
    
    func testKerningAttribute() throws {
        let view = Text("Test").italic().kerning(7)
        let sut = try view.inspect().text().attributes()
        XCTAssertEqual(try sut.kerning(), 7)
    }
    
    func testTrackingAttribute() throws {
        let view = Text("Test").italic().tracking(4)
        let sut = try view.inspect().text().attributes()
        XCTAssertEqual(try sut.tracking(), 4)
    }
    
    func testBaselineOffsetAttribute() throws {
        let view = Text("Test").italic().baselineOffset(6)
        let sut = try view.inspect().text().attributes()
        XCTAssertEqual(try sut.baselineOffset(), 6)
    }
    
    func testAttributesForConcatenatedText() throws {
        let view = Text("Te").kerning(2).bold() + Text("st").bold().italic()
        let sut = try view.inspect().text().attributes()

        XCTAssertTrue(try sut.isBold())
        XCTAssertThrows(try sut.isItalic(), "Modifier 'italic' is applied only to a subrange")
    }

    func testAttributeRangesForConcatenatedText() throws {
        let view = Text("Te").bold() + Text("st").italic() + Text("123").bold().italic()
        let sut = try view.inspect().text().attributes()

        XCTAssertTrue(try sut[0..<2].isBold())
        XCTAssertTrue(try sut[1..<2].isBold())
        XCTAssertTrue(try sut[2..<4].isItalic())
        XCTAssertTrue(try sut[2..<6].isItalic())
        XCTAssertTrue(try sut[3..<5].isItalic())
        XCTAssertThrows(try sut[0..<4].isItalic(), "Modifier 'italic' is applied only to a subrange")
        XCTAssertThrows(try sut.isBold(), "Modifier 'bold' is applied only to a subrange")
        XCTAssertTrue(try sut[..<2].isBold())
        XCTAssertTrue(try sut[0...1].isBold())
        XCTAssertTrue(try sut[...1].isBold())
        XCTAssertTrue(try sut[5...].isBold())
    }
    
    func testAttributeLookupErrors() throws {
        let view1 = Text("Test").bold().kerning(5)
        let sut1 = try view1.inspect().text().attributes()
        XCTAssertThrows(try sut1[10..<14].isBold(), "Invalid text range")
        
        let view2 = Text("Te").kerning(2) + Text("st").kerning(4)
        let sut2 = try view2.inspect().text().attributes()
        XCTAssertThrows(try sut2.kerning(), "Modifier 'kerning' has different values in subranges")
    }

    func testAttributeRangesForConcatenatedTextUsingStringRange() throws {
        let text = Text("bold").bold() + Text(" ") + Text("italic").italic()
        let inspectableText = try text.inspect().text()
        let string = try XCTUnwrap(try inspectableText.string())
        let attributes = try inspectableText.attributes()

        let boldTextRange = try XCTUnwrap(string.range(of: "bold"))
        XCTAssertTrue(try attributes[boldTextRange].isBold())

        let italicTextRange = try XCTUnwrap(string.range(of: "italic"))
        XCTAssertTrue(try attributes[italicTextRange].isItalic())
    }

    func testAttributeRangesForConcatenatedTextUsingRangeExpressions() throws {
        let text = Text("bold").bold() + Text(" ") + Text("italic").italic()
        let inspectableText = try text.inspect().text()
        let string = try XCTUnwrap(try inspectableText.string())
        let attributes = try inspectableText.attributes()

        let endOfBoldIndex = string.index(string.startIndex, offsetBy: 4)
        XCTAssertTrue(try attributes[..<endOfBoldIndex].isBold())
        XCTAssertThrows(try attributes[string.startIndex...endOfBoldIndex].isBold(),
                        "Modifier 'bold' is applied only to a subrange")
        XCTAssertTrue(try attributes[string.index(endOfBoldIndex, offsetBy: 2)...].isItalic())
    }
}

// MARK: - View Modifiers

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class GlobalModifiersForText: XCTestCase {
    
    func testFont() throws {
        let sut = EmptyView().font(.body)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testLineLimit() throws {
        let sut = EmptyView().lineLimit(5)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testLineSpacing() throws {
        let sut = EmptyView().lineSpacing(5)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testMultilineTextAlignment() throws {
        let sut = EmptyView().multilineTextAlignment(.center)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testMinimumScaleFactor() throws {
        let sut = EmptyView().minimumScaleFactor(5)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testTruncationMode() throws {
        let sut = EmptyView().truncationMode(.tail)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testAllowsTightening() throws {
        let sut = EmptyView().allowsTightening(true)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testFlipsForRightToLeftLayoutDirection() throws {
        let sut = EmptyView().flipsForRightToLeftLayoutDirection(true)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
final class TextImageTests: XCTestCase {

    func testTextImage() throws {
        let text = Text(Image("someImage"))
        XCTAssertNoThrow(try text.inspect().text().image())
    }
}
