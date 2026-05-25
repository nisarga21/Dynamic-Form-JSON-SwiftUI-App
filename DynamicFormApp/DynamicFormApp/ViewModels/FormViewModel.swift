//
//  FormViewModel.swift
//  DynamicFormApp
//
//  Created by Nisarga V S on 23/05/26.
//

import SwiftUI
import Combine

class FormViewModel: ObservableObject {
    @Published var fieldValues: [String: Any] = [:]
    @Published var fieldErrors: [String: String] = [:]
    @Published var submitError: String?
    @Published var submitSuccess = false
    
    let fields: [FormField]
    let theme: Theme
    private var cancellables = Set<AnyCancellable>()
    
    // For focus management
    @Published var focusedFieldId: String?
    let textFieldIds: [String]

    init(formDefinition: FormDefinition) {
        self.fields = formDefinition.fields.sorted { $0.order < $1.order }
        self.theme = formDefinition.theme ?? Theme.default
        
        // Collect text field IDs for focus management - do this early
        self.textFieldIds = fields.compactMap { field in
            if case .text = field { return field.id }
            return nil
        }

        // Initialize field values with defaults
        for field in fields {
            switch field {
            case .text:
                fieldValues[field.id] = ""
            case .dropdown(let config):
                if let defaults = config.defaultValues, !defaults.isEmpty {
                    if config.allowMultiple {
                        fieldValues[field.id] = Set(defaults)
                    } else {
                        fieldValues[field.id] = defaults.first
                    }
                } else {
                    if config.allowMultiple {
                        fieldValues[field.id] = Set<String>()
                    } else {
                        fieldValues[field.id] = nil as String?
                    }
                }
            case .checkbox:
                fieldValues[field.id] = false
            }
        }

        // Validate on value change
        $fieldValues
            .sink { [weak self] _ in
                self?.validateAllFields()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Value Accessors
    func textValue(for id: String) -> String {
        fieldValues[id] as? String ?? ""
    }
    
    func setTextValue(_ value: String, for id: String) {
        fieldValues[id] = value
    }
    
    func dropdownSingleValue(for id: String) -> String? {
        fieldValues[id] as? String
    }
    
    func dropdownMultipleValue(for id: String) -> Set<String> {
        fieldValues[id] as? Set<String> ?? []
    }
    
    func setDropdownSingleValue(_ value: String?, for id: String) {
        fieldValues[id] = value
    }
    
    func setDropdownMultipleValue(_ value: Set<String>, for id: String) {
        fieldValues[id] = value
    }
    
    func checkboxValue(for id: String) -> Bool {
        fieldValues[id] as? Bool ?? false
    }
    
    func setCheckboxValue(_ value: Bool, for id: String) {
        fieldValues[id] = value
    }
    
    // MARK: - Validation
    func validateField(_ field: FormField) -> String? {
        switch field {
        case .text(let config):
            let value = textValue(for: config.id)
            return FieldValidator.validateText(value: value, config: config)
        case .dropdown(let config):
            if config.allowMultiple {
                let value = dropdownMultipleValue(for: config.id)
                return FieldValidator.validateMultiDropdown(value: value, config: config)
            } else {
                let value = dropdownSingleValue(for: config.id)
                return FieldValidator.validateSingleDropdown(value: value, config: config)
            }
        case .checkbox(let config):
            let value = checkboxValue(for: config.id)
            return FieldValidator.validateCheckbox(value: value, config: config)
        }
    }
    
    func validateAllFields() {
        var newErrors: [String: String] = [:]
        for field in fields {
            if let error = validateField(field) {
                newErrors[field.id] = error
            }
        }
        fieldErrors = newErrors
    }
    
    func submitForm() -> Bool {
        validateAllFields()
        if fieldErrors.isEmpty {
            submitSuccess = true
            submitError = nil
            return true
        } else {
            submitError = "Please fix the errors above"
            submitSuccess = false
            return false
        }
    }
    
    func dismissSuccess() {
        submitSuccess = false
    }
}
