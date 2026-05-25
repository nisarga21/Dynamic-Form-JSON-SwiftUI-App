//
//  Theme.swift
//  DynamicFormApp
//
//  Created by Nisarga V S on 23/05/26.
//

import SwiftUI

struct Theme: Codable {
    let backgroundColor: String
    let textColor: String
    let borderColor: String
    let errorColor: String
    
    enum CodingKeys: String, CodingKey {
        case backgroundColor = "background_color"
        case textColor = "text_color"
        case borderColor = "border_color"
        case errorColor = "error_color"
    }
    
    // Default theme for resilience
    static let `default` = Theme(
        backgroundColor: "#FFFFFF",
        textColor: "#000000",
        borderColor: "#CCCCCC",
        errorColor: "#FF3B30"
    )
    
    func toUIColor() -> (bg: Color, text: Color, border: Color, error: Color) {
        (
            bg: Color(hex: backgroundColor),
            text: Color(hex: textColor),
            border: Color(hex: borderColor),
            error: Color(hex: errorColor)
        )
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
