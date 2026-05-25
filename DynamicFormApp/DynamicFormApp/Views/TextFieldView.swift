//
//  TextFieldView.swift
//  DynamicFormApp
//
//  Created by Nisarga V S on 23/05/26.
//

import SwiftUI

struct TextFieldView: View {
    let config: TextFormField
    @Binding var value: String
    let error: String?
    let theme: Theme
    var onCommit: (() -> Void)? = nil
    @FocusState.Binding var focusedFieldId: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            TextField(
                config.placeholder ?? "",
                text: $value
            )
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .keyboardType(config.subtype == .number ? .decimalPad : .default)
            .focused($focusedFieldId, equals: config.id)
            .onSubmit {
                onCommit?()
            }
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(theme.toUIColor().border, lineWidth: 1)
            )
            
            if let error = error {
                Text(error)
                    .font(.caption)
                    .foregroundColor(theme.toUIColor().error)
            }
        }
    }
}
