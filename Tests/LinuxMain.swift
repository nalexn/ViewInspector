import XCTest

import ViewInspectorTests

var tests = [XCTestCaseEntry]()
tests += AnyViewTests.allTests
tests += ButtonTests.allTests
tests += CustomViewTests.allTests
tests += HStackTests.allTests
tests += TextTests.allTests
XCTMain(tests)
