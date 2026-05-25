//
//  ValidationTests.swift
//  DynamicFormAppTests
//
//  Created by Nisarga V S on 23/05/26.
//

import XCTest
@testable import DynamicFormApp

final class ValidationTests: XCTestCase {
    func testTextValidationRequired() {
        let config = TextFormField(id: "t", order: 1, required: true, placeholder: nil, maxLength: nil, errorMessage: nil, regex: nil, subtype: .plain)
        let error = FieldValidator.validateText(value: "", config: config)
        XCTAssertNotNil(error)
        let error2 = FieldValidator.validateText(value: "abc", config: config)
        XCTAssertNil(error2)
    }
    
    func testTextMaxLength() {
        let config = TextFormField(id: "t", order: 1, required: false, placeholder: nil, maxLength: 3, errorMessage: nil, regex: nil, subtype: .plain)
        let error = FieldValidator.validateText(value: "abcd", config: config)
        XCTAssertNotNil(error)
        let error2 = FieldValidator.validateText(value: "abc", config: config)
        XCTAssertNil(error2)
    }
    
    func testNumberSubtypeValidation() {
        let config = TextFormField(id: "t", order: 1, required: true, placeholder: nil, maxLength: nil, errorMessage: nil, regex: nil, subtype: .number)
        let error = FieldValidator.validateText(value: "12.34", config: config)
        XCTAssertNil(error)
        let error2 = FieldValidator.validateText(value: "abc", config: config)
        XCTAssertNotNil(error2)
    }
    
    func testCheckboxRequired() {
        let config = CheckboxFormField(id: "c", order: 1, required: true, label: "Agree", metadata: nil, clickableTextColor: nil)
        let error = FieldValidator.validateCheckbox(value: false, config: config)
        XCTAssertNotNil(error)
        let error2 = FieldValidator.validateCheckbox(value: true, config: config)
        XCTAssertNil(error2)
    }
}
