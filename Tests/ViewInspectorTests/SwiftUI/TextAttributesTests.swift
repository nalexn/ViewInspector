import XCTest
import SwiftUI
@testable import ViewInspector

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class TextAttributesTests: XCTestCase {

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
    
    func testNaiveFontInspectionError() throws {
        let sut = Text("Test").font(.body)
        XCTAssertThrows(try sut.inspect().text().font(),
                        "Please use .attributes().font() for inspecting Font on a Text")
        XCTAssertEqual(try sut.inspect().text().attributes().font(), .body)
    }
    
    func testFontAttribute() throws {
        let system = Font.system(size: 24, weight: .semibold, design: .rounded)
        let view1 = Text("Test").kerning(2).font(system)
        let sut1 = try view1.inspect().text().attributes()
        XCTAssertEqual(try sut1.font(), system)
        let system2 = Font.system(.largeTitle)
        let view2 = Text("Test").kerning(2).font(system2)
        let sut2 = try view2.inspect().text().attributes()
        XCTAssertEqual(try sut2.font(), .largeTitle)
        let custom = Font.custom("Avenir-Roman", size: 15)
        let view3 = Text("Test").font(custom)
        let sut3 = try view3.inspect().text().attributes()
        XCTAssertEqual(try sut3.font(), custom)
    }
    
    func testEnvironmentFontAttribute() throws {
        let sut1 = Group { Group { Text("").font(.caption) }.font(.body) }.font(.title)
        XCTAssertEqual(try sut1.inspect().find(ViewType.Text.self).attributes().font(), .caption)
        XCTAssertThrows(try sut1.inspect().find(ViewType.Text.self).font(),
                        "Please use .attributes().font() for inspecting Font on a Text")
        
        let sut2 = Group { Group { Text("") }.font(.body) }.font(.title)
        XCTAssertEqual(try sut2.inspect().find(ViewType.Text.self).attributes().font(), .body)
        XCTAssertThrows(try sut2.inspect().find(ViewType.Text.self).font(),
                        "Please use .attributes().font() for inspecting Font on a Text")
    }
    
    func testEnvironmentForegroundColorAttribute() throws {
        let sut1 = Group { Group { Text("").foregroundColor(.red) }
            .foregroundColor(.green) }.foregroundColor(.blue)
        XCTAssertEqual(try sut1.inspect().find(ViewType.Text.self)
                        .attributes().foregroundColor(), .red)
        XCTAssertThrows(try sut1.inspect().find(ViewType.Text.self).foregroundColor(),
            "Please use .attributes().foregroundColor() for inspecting foregroundColor on a Text")
        
        let sut2 = Group { Group { Text("") }
            .foregroundColor(.green) }.foregroundColor(.blue)
        XCTAssertEqual(try sut2.inspect().find(ViewType.Text.self)
                        .attributes().foregroundColor(), .green)
        XCTAssertThrows(try sut2.inspect().find(ViewType.Text.self).foregroundColor(),
            "Please use .attributes().foregroundColor() for inspecting foregroundColor on a Text")
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
        XCTAssertTrue(try sut.isStrikethrough())
        XCTAssertEqual(try sut.strikethroughColor(), .black)
        if #available(iOS 15.0, tvOS 15.0, macOS 12.0, watchOS 8.0, *) {
            XCTAssertEqual(try sut.strikethroughStyle(), .single)
        }
    }
    
    func testUnderlineAttribute() throws {
        let view = Text("Test").bold().underline(true, color: .black)
        let sut = try view.inspect().text().attributes()
        XCTAssertTrue(try sut.isUnderline())
        XCTAssertEqual(try sut.underlineColor(), .black)
        if #available(iOS 15.0, tvOS 15.0, macOS 12.0, watchOS 8.0, *) {
            XCTAssertEqual(try sut.underlineStyle(), .single)
        }
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

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class FontAttributesTests: XCTestCase {
    
    func testSizeAttribute() throws {
        let sut1 = Font.custom("abc", size: 13)
        let sut2 = Font.system(size: 15, weight: .bold, design: .rounded)
        let sut3 = Font.headline
        XCTAssertEqual(try sut1.size(), 13)
        XCTAssertFalse(sut1.isFixedSize())
        XCTAssertEqual(try sut2.size(), 15)
        XCTAssertFalse(sut2.isFixedSize())
        XCTAssertThrows(try sut3.size(),
                        "Font does not have 'size' attribute")
        XCTAssertFalse(sut3.isFixedSize())
        if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
            let sut4 = Font.custom("abc", fixedSize: 16)
            XCTAssertEqual(try sut4.size(), 16)
            XCTAssertTrue(sut4.isFixedSize())
        }
    }
    
    func testNameAttribute() throws {
        let sut1 = Font.custom("abc", size: 13)
        let sut2 = Font.system(size: 40)
        XCTAssertEqual(try sut1.name(), "abc")
        XCTAssertThrows(try sut2.name(), "Font does not have 'name' attribute")
    }
    
    func testWeightAttribute() throws {
        let sut1 = Font.system(size: 14, weight: .heavy)
        let sut2 = Font.system(size: 13)
        let sut3 = Font.custom("abc", size: 14)
        XCTAssertEqual(try sut1.weight(), .heavy)
        XCTAssertEqual(try sut2.weight(), .regular)
        XCTAssertThrows(try sut3.weight(), "Font does not have 'weight' attribute")
    }
    
    func testDesignAttribute() throws {
        let sut1 = Font.system(size: 14, design: .rounded)
        let sut2 = Font.system(size: 13)
        let sut3 = Font.custom("abc", size: 14)
        XCTAssertEqual(try sut1.design(), .rounded)
        XCTAssertEqual(try sut2.design(), .`default`)
        XCTAssertThrows(try sut3.design(), "Font does not have 'design' attribute")
    }
    
    func testStyleAttribute() throws {
        let sut1 = Font.callout
        let sut2 = Font.system(size: 15)
        let sut3 = Font.custom("abc", size: 15)
        XCTAssertEqual(try sut1.style(), .callout)
        XCTAssertThrows(try sut2.style(), "Font does not have 'style' attribute")
        if #available(iOS 14.0, macOS 11.0, tvOS 14.0, *) {
            XCTAssertEqual(try sut3.style(), .body)
        } else {
            XCTAssertThrows(try sut3.style(), "Font does not have 'style' attribute")
        }
        if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
            let sut4 = Font.custom("abc", size: 14, relativeTo: .caption2)
            XCTAssertEqual(try sut4.style(), .caption2)
        }
    }
}
