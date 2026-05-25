//
//  FormField.swift
//  DynamicFormApp
//
//  Created by Nisarga V S on 23/05/26.
//

import Foundation

// MARK: - FormField Enum (Polymorphic)
enum FormField: Identifiable {
    case text(TextFormField)
    case dropdown(DropdownFormField)
    case checkbox(CheckboxFormField)
    
    var id: String {
        switch self {
        case .text(let field): return field.id
        case .dropdown(let field): return field.id
        case .checkbox(let field): return field.id
        }
    }
    
    var order: Int {
        switch self {
        case .text(let field): return field.order
        case .dropdown(let field): return field.order
        case .checkbox(let field): return field.order
        }
    }
}

// MARK: - Text Field Configuration
struct TextFormField: Codable {
    let id: String
    let order: Int
    let required: Bool
    let placeholder: String?
    let maxLength: Int?
    let errorMessage: String?
    let regex: String?
    let subtype: TextSubtype?
    
    enum TextSubtype: String, Codable {
        case plain = "PLAIN"
        case number = "NUMBER"
    }
    
    enum CodingKeys: String, CodingKey {
        case id, order, required, placeholder, maxLength, errorMessage, regex, subtype
    }
}

// MARK: - Dropdown Field Configuration
struct DropdownFormField: Codable {
    let id: String
    let order: Int
    let required: Bool
    let allowMultiple: Bool
    let options: [DropdownOption]
    let defaultValues: [String]?
    
    enum CodingKeys: String, CodingKey {
        case id, order, required, options, defaultValues
        case allowMultiple = "allow_multiple"
    }
}

struct DropdownOption: Codable, Identifiable {
    let id: String
    let label: String
}

// MARK: - Checkbox Field Configuration
struct CheckboxFormField: Codable {
    let id: String
    let order: Int
    let required: Bool
    let label: String
    let metadata: [String: String]?
    let clickableTextColor: String?
    
    enum CodingKeys: String, CodingKey {
        case id, order, required, label, metadata
        case clickableTextColor = "clickable_text_color"
    }
}

// MARK: - Custom Decoding for Polymorphism
extension FormField: Decodable {
    enum DiscriminatorKeys: String, CodingKey {
        case type
    }
    
    enum FieldType: String, Decodable {
        case text = "TEXT"
        case dropdown = "DROPDOWN"
        case checkbox = "CHECKBOX"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DiscriminatorKeys.self)
        let type = try container.decode(FieldType.self, forKey: .type)
        
        switch type {
        case .text:
            let field = try TextFormField(from: decoder)
            self = .text(field)
        case .dropdown:
            let field = try DropdownFormField(from: decoder)
            self = .dropdown(field)
        case .checkbox:
            let field = try CheckboxFormField(from: decoder)
            self = .checkbox(field)
        }
    }
}
