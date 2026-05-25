//
//  ThemeManager.swift
//  DynamicFormApp
//
//  Created by Nisarga V S on 23/05/26.
//

import SwiftUI

struct ThemeManager {
    static func applyTheme(_ theme: Theme, to view: some View) -> some View {
        let colors = theme.toUIColor()
        return view
            .background(colors.bg)
            .foregroundColor(colors.text)
            .accentColor(colors.border)
    }
}
