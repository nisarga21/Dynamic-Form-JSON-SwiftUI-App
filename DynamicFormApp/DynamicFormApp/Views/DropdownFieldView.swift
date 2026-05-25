//
//  DropdownFieldView.swift
//  DynamicFormApp
//
//  Created by Nisarga V S on 23/05/26.
//

import SwiftUI

struct DropdownFieldView: View {
    let config: DropdownFormField
    @Binding var singleValue: String?
    @Binding var multiValue: Set<String>
    let error: String?
    let theme: Theme
    
    @State private var showMultiSheet = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if config.allowMultiple {
                // Multiple selection
                Button(action: { showMultiSheet = true }) {
                    HStack {
                        Text(selectedLabelsText)
                            .foregroundColor(selectedLabelsText.isEmpty ? .gray : .primary)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .font(.caption)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 8).stroke(theme.toUIColor().border))
                }
                .sheet(isPresented: $showMultiSheet) {
                    MultiSelectSheet(options: config.options, selected: $multiValue)
                }
            } else {
                // Single selection
                Menu {
                    ForEach(config.options) { option in
                        Button(option.label) {
                            singleValue = option.id
                        }
                    }
                } label: {
                    HStack {
                        Text(selectedSingleLabel)
                            .foregroundColor(singleValue == nil ? .gray : .primary)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .font(.caption)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 8).stroke(theme.toUIColor().border))
                }
            }
            
            if let error = error {
                Text(error)
                    .font(.caption)
                    .foregroundColor(theme.toUIColor().error)
            }
        }
    }
    
    private var selectedSingleLabel: String {
        guard let id = singleValue,
              let option = config.options.first(where: { $0.id == id }) else {
            return "Select an option"
        }
        return option.label
    }
    
    private var selectedLabelsText: String {
        let selectedOptions = config.options.filter { multiValue.contains($0.id) }
        if selectedOptions.isEmpty {
            return "Select options"
        }
        return selectedOptions.map { $0.label }.joined(separator: ", ")
    }
}
