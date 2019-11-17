import XCTest

import ViewInspectorTests

var tests = [XCTestCaseEntry]()
tests += AnyViewTests.allTests
tests += BaseTypesTests.allTests
tests += ButtonTests.allTests
tests += CustomViewTests.allTests
tests += InspectorTests.allTests
tests += HStackTests.allTests
tests += TextTests.allTests
tests += VStackTests.allTests
XCTMain(tests)
