//
//  FieldValidator.swift
//  DynamicFormApp
//
//  Created by Nisarga V S on 23/05/26.
//

import Foundation

struct FieldValidator {
    static func validateText(value: String, config: TextFormField) -> String? {
        // Required
        if config.required && value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return config.errorMessage ?? "This field is required"
        }
        
        // If not required and empty, skip further validation
        if !config.required && value.isEmpty {
            return nil
        }
        
        // Max length
        if let maxLength = config.maxLength, value.count > maxLength {
            return "Maximum \(maxLength) characters allowed"
        }
        
        // Number validation (if subtype is number)
        if config.subtype == .number {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            if formatter.number(from: value) == nil && !value.isEmpty {
                return "Must be a valid number"
            }
        }
        
        // Custom regex
        if let regexPattern = config.regex, !value.isEmpty {
            let predicate = NSPredicate(format: "SELF MATCHES %@", regexPattern)
            if !predicate.evaluate(with: value) {
                return config.errorMessage ?? "Invalid format"
            }
        }
        
        return nil
    }
    
    static func validateSingleDropdown(value: String?, config: DropdownFormField) -> String? {
        if config.required && (value == nil || value?.isEmpty == true) {
            return "Please select an option"
        }
        return nil
    }
    
    static func validateMultiDropdown(value: Set<String>, config: DropdownFormField) -> String? {
        if config.required && value.isEmpty {
            return "Please select at least one option"
        }
        return nil
    }
    
    static func validateCheckbox(value: Bool, config: CheckboxFormField) -> String? {
        if config.required && !value {
            return "You must agree to continue"
        }
        return nil
    }
}
