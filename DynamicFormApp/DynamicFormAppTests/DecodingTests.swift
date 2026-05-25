//
//  DecodingTests.swift
//  DecodingTests
//
//  Created by Nisarga V S on 23/05/26.
//

import XCTest
@testable import DynamicFormApp

final class DecodingTests: XCTestCase {
    func testDecodeFullForm() throws {
        let json = """
        {
            "theme": {
                "background_color": "#FFF",
                "text_color": "#000",
                "border_color": "#CCC",
                "error_color": "#F00"
            },
            "form_title": "Test Form",
            "fields": [
                {
                    "id": "f1",
                    "order": 1,
                    "type": "TEXT",
                    "required": true,
                    "placeholder": "Name"
                }
            ]
        }
        """
        let data = json.data(using: .utf8)!
        let form = try JSONDecoder().decode(FormDefinition.self, from: data)
        XCTAssertEqual(form.formTitle, "Test Form")
        XCTAssertEqual(form.fields.count, 1)
        if case .text(let config) = form.fields[0] {
            XCTAssertEqual(config.id, "f1")
            XCTAssertEqual(config.placeholder, "Name")
        } else {
            XCTFail("Expected text field")
        }
    }
    
    func testMissingThemeUsesDefault() throws {
        let json = """
        {
            "form_title": "No Theme",
            "fields": []
        }
        """
        let data = json.data(using: .utf8)!
        let form = try JSONDecoder().decode(FormDefinition.self, from: data)
        XCTAssertNotNil(form.theme)
        XCTAssertEqual(form.theme?.backgroundColor, Theme.default.backgroundColor)
    }
    
    func testPolymorphicDecoding() throws {
        let json = """
        {
            "form_title": "Mixed Fields",
            "fields": [
                { "id": "t1", "order": 1, "type": "TEXT", "required": false },
                { "id": "d1", "order": 2, "type": "DROPDOWN", "required": true, "allow_multiple": false, "options": [] },
                { "id": "c1", "order": 3, "type": "CHECKBOX", "required": false, "label": "Check" }
            ]
        }
        """
        let data = json.data(using: .utf8)!
        let form = try JSONDecoder().decode(FormDefinition.self, from: data)
        XCTAssertEqual(form.fields.count, 3)
        XCTAssertTrue(form.fields[0].id == "t1")
        XCTAssertTrue(form.fields[1].id == "d1")
        XCTAssertTrue(form.fields[2].id == "c1")
    }
}
