//
//  FormDefinition.swift
//  DynamicFormApp
//
//  Created by Nisarga V S on 23/05/26.
//

import Foundation

struct FormDefinition: Decodable {
    let theme: Theme?
    let formTitle: String
    let fields: [FormField]
    
    enum CodingKeys: String, CodingKey {
        case theme
        case formTitle = "form_title"
        case fields
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // Theme can be missing – fallback to default
        self.theme = try container.decodeIfPresent(Theme.self, forKey: .theme) ?? Theme.default
        self.formTitle = try container.decode(String.self, forKey: .formTitle)
        self.fields = try container.decode([FormField].self, forKey: .fields)
    }
}
