import XCTest

import ViewInspectorTests

var tests = [XCTestCaseEntry]()
tests += AnyViewTests.allTests
tests += HStackTests.allTests
tests += TextTests.allTests
XCTMain(tests)
