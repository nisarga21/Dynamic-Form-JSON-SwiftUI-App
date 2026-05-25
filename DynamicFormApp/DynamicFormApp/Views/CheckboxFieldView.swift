//
//  CheckboxFieldView.swift
//  DynamicFormApp
//
//  Created by Nisarga V S on 23/05/26.
//

import SwiftUI

struct CheckboxFieldView: View {
    let config: CheckboxFormField
    @Binding var isChecked: Bool
    let error: String?
    let theme: Theme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Toggle(isOn: $isChecked) {
                AttributedText(
                    label: config.label,
                    metadata: config.metadata ?? [:],
                    defaultColor: theme.toUIColor().text,
                    clickableColor: config.clickableTextColor.map { Color(hex: $0) } ?? theme.toUIColor().text
                )
            }
            .toggleStyle(iOSCheckboxToggleStyle())
            
            if let error = error {
                Text(error)
                    .font(.caption)
                    .foregroundColor(theme.toUIColor().error)
            }
        }
    }
}

// Custom toggle style for checkbox
struct iOSCheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: { configuration.isOn.toggle() }) {
            HStack {
                Image(systemName: configuration.isOn ? "checkmark.square" : "square")
                    .foregroundColor(configuration.isOn ? .blue : .secondary)
                configuration.label
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Rich text view with clickable links
struct AttributedText: View {
    let label: String
    let metadata: [String: String]
    let defaultColor: Color
    let clickableColor: Color
    
    var body: some View {
        if metadata.isEmpty {
            Text(label)
                .foregroundColor(defaultColor)
        } else {
            Text(attributedString)
        }
    }
    
    private var attributedString: AttributedString {
        var result = AttributedString(label)
        result.foregroundColor = UIColor(defaultColor)
        
        for (substring, urlString) in metadata {
            guard let range = result.range(of: substring),
                  let url = URL(string: urlString) else { continue }
            result[range].link = url
            result[range].foregroundColor = UIColor(clickableColor)
            result[range].underlineStyle = .single
        }
        return result
    }
}
