import XCTest
@testable import CustomerGlu

final class CustomerGluTests: XCTestCase {

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(CustomerGlu.single_instance.text, "Hello, World!")
    }
}
