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
            
       // app.buttons["SUBMIT"].tap()

       // app.buttons["Wallet"].tap()
        
//        let app = XCUIApplication()
//        app.textFields["UserId"].tap()
//
//        let usernameTextField = app.textFields["Username"]
//        usernameTextField.tap()
//        usernameTextField.tap()
        //app.buttons["SUBMIT"].tap()
       // app.buttons["Wallet"].tap()
       // app.webViews.webViews.webViews/*@START_MENU_TOKEN@*/.otherElements["banner"]/*[[".otherElements[\"Home\"].otherElements[\"banner\"]",".otherElements[\"banner\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.children(matching: .button).element.tap()
    }
}
