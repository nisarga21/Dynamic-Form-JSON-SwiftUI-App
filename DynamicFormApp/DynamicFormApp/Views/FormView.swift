//
//  FormView.swift
//  DynamicFormApp
//
//  Created by Nisarga V S on 23/05/26.
//

import SwiftUI

struct FormView: View {
    @StateObject var viewModel: FormViewModel
    @FocusState private var focusedFieldId: String?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ForEach(viewModel.fields) { field in
                    fieldView(for: field)
                        .padding(.horizontal)
                }
                
                Button("Submit") {
                    if viewModel.submitForm() {
                        // Success handling: could show alert or navigation
                    }
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal)
                
                if let submitError = viewModel.submitError {
                    Text(submitError)
                        .foregroundColor(viewModel.theme.toUIColor().error)
                        .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .background(viewModel.theme.toUIColor().bg)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                if let current = focusedFieldId,
                   let index = viewModel.textFieldIds.firstIndex(of: current),
                   index < viewModel.textFieldIds.count - 1 {
                    Button("Next") {
                        let nextId = viewModel.textFieldIds[index + 1]
                        focusedFieldId = nextId
                    }
                }
                Button("Done") {
                    focusedFieldId = nil
                }
            }
        }
        .alert("Success", isPresented: $viewModel.submitSuccess) {
            Button("OK") {
                viewModel.dismissSuccess()
                dismiss()
            }
        } message: {
            Text("Form submitted successfully!")
        }
        .bindFocus($focusedFieldId, to: $viewModel.focusedFieldId)
    }
    
    @ViewBuilder
    private func fieldView(for field: FormField) -> some View {
        switch field {
        case .text(let config):
            TextFieldView(
                config: config,
                value: Binding(
                    get: { viewModel.textValue(for: config.id) },
                    set: { viewModel.setTextValue($0, for: config.id) }
                ),
                error: viewModel.fieldErrors[config.id],
                theme: viewModel.theme,
                onCommit: {
                    // Move to next text field automatically on return
                    if let currentIndex = viewModel.textFieldIds.firstIndex(of: config.id),
                       currentIndex < viewModel.textFieldIds.count - 1 {
                        focusedFieldId = viewModel.textFieldIds[currentIndex + 1]
                    } else {
                        focusedFieldId = nil
                    }
                },
                focusedFieldId: $focusedFieldId
            )
            
        case .dropdown(let config):
            if config.allowMultiple {
                DropdownFieldView(
                    config: config,
                    singleValue: .constant(nil),
                    multiValue: Binding(
                        get: { viewModel.dropdownMultipleValue(for: config.id) },
                        set: { viewModel.setDropdownMultipleValue($0, for: config.id) }
                    ),
                    error: viewModel.fieldErrors[config.id],
                    theme: viewModel.theme
                )
            } else {
                DropdownFieldView(
                    config: config,
                    singleValue: Binding(
                        get: { viewModel.dropdownSingleValue(for: config.id) },
                        set: { viewModel.setDropdownSingleValue($0, for: config.id) }
                    ),
                    multiValue: .constant([]),
                    error: viewModel.fieldErrors[config.id],
                    theme: viewModel.theme
                )
            }
            
        case .checkbox(let config):
            CheckboxFieldView(
                config: config,
                isChecked: Binding(
                    get: { viewModel.checkboxValue(for: config.id) },
                    set: { viewModel.setCheckboxValue($0, for: config.id) }
                ),
                error: viewModel.fieldErrors[config.id],
                theme: viewModel.theme
            )
        }
    }
}

extension View {
    func bindFocus(_ focused: FocusState<String?>.Binding, to published: Binding<String?>) -> some View {
        self
            .onChange(of: focused.wrappedValue) { newValue in
                published.wrappedValue = newValue
            }
            .onChange(of: published.wrappedValue) { newValue in
                focused.wrappedValue = newValue
            }
    }
}
