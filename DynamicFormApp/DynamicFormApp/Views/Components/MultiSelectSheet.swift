//
//  MultiSelectSheet.swift
//  DynamicFormApp
//
//  Created by Nisarga V S on 23/05/26.
//

import SwiftUI

struct MultiSelectSheet: View {
    let options: [DropdownOption]
    @Binding var selected: Set<String>
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List(options) { option in
                Button(action: {
                    if selected.contains(option.id) {
                        selected.remove(option.id)
                    } else {
                        selected.insert(option.id)
                    }
                }) {
                    HStack {
                        Text(option.label)
                        Spacer()
                        if selected.contains(option.id) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
                .foregroundColor(.primary)
            }
            .navigationTitle("Select Options")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
