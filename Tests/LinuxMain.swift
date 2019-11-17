import XCTest

import ViewInspectorTests

var tests = [XCTestCaseEntry]()
tests += AnyViewTests.allTests
tests += BaseTypesTests.allTests
tests += ButtonTests.allTests
tests += CustomViewTests.allTests
tests += FormTests.allTests
tests += GroupTests.allTests
tests += HStackTests.allTests
tests += ImageTests.allTests
tests += InspectorTests.allTests
tests += ScrollViewTests.allTests
tests += SectionTests.allTests
tests += TextTests.allTests
tests += VStackTests.allTests
tests += ZStackTests.allTests
XCTMain(tests)
