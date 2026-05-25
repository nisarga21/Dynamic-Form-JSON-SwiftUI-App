//
//  ContentView.swift
//  DynamicFormApp
//
//  Created by Nisarga V S on 23/05/26.
//

//
//  ContentView.swift
//  DynamicFormApp
//
//  Created by Nisarga V S on 23/05/26.
//

import SwiftUI

struct ContentView: View {
    @State private var formDefinition: FormDefinition?
    @State private var loadError: String?

    var body: some View {
        Group {
            if let definition = formDefinition {
                // Single screen: the form itself
                FormView(viewModel: FormViewModel(formDefinition: definition))
            } else if let error = loadError {
                // Show error, but still a single screen (no navigation)
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.orange)
                    Text("Failed to load form")
                        .font(.headline)
                    Text(error)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding()
            } else {
                // Loading state (rare, but safe)
                ProgressView("Loading form...")
                    .onAppear(perform: loadFormFromBundle)
            }
        }
        .onAppear(perform: loadFormFromBundle)
    }

    private func loadFormFromBundle() {
        // 1. Locate the JSON file in the app bundle
        guard let url = Bundle.main.url(forResource: "form", withExtension: "json") else {
            loadError = "form.json not found in app bundle."
            return
        }

        // 2. Read data
        guard let data = try? Data(contentsOf: url) else {
            loadError = "Could not read form.json."
            return
        }

        // 3. Decode
        do {
            let decoder = JSONDecoder()
            let definition = try decoder.decode(FormDefinition.self, from: data)
            formDefinition = definition
            loadError = nil
        } catch {
            loadError = "JSON parsing failed: \(error.localizedDescription)"
        }
    }
}
