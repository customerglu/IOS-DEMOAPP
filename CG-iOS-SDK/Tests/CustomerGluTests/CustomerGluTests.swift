    import XCTest
    @testable import CustomerGlu

    final class CustomerGluTests: XCTestCase {
        @available(iOS 13.0, *)
        func testExample() {
            // This is an example of a functional test case.
            // Use XCTAssert and related functions to verify your tests produce the correct
            // results.
            XCTAssertEqual(CustomerGlu().text, "Hello, World!")
        }
    }
