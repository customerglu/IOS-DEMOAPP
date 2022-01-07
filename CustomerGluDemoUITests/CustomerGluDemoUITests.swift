//
//  CustomerGluDemoUITests.swift
//  CustomerGluDemoUITests
//
//  Created by kapil on 06/01/22.
//

import XCTest

class CustomerGluDemoUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }
  
    func testValidLoginDetails() {
        let validUserId = "demo123"
        let validUserName = "demo"
        
        let app = XCUIApplication()
        let useridTextFiled = app.textFields["UserId"]
        XCTAssertTrue(useridTextFiled.exists)
        useridTextFiled.tap()
        useridTextFiled.typeText(validUserId)
        
        let usernameTextField = app.textFields["Username"]
        XCTAssertTrue(usernameTextField.exists)
        usernameTextField.tap()
        usernameTextField.typeText(validUserName)
            
        app.buttons["SUBMIT"].tap()
       // app.buttons["Wallet"].tap()
    }
}
