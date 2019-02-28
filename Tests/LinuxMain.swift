import XCTest

import aqueductTests

var tests = [XCTestCaseEntry]()
tests += aqueductTests.allTests()
XCTMain(tests)