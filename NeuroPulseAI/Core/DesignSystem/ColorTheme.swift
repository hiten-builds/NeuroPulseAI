//
//  ColorTheme.swift
//  NeuroPulseAI
//
//  Design system color tokens supporting dynamic light and dark modes.
//

import SwiftUI

public extension Color {
    /// NeuroPulse AI brand palette tokens
    enum NeuroPulse {
        // MARK: - Core Accents
        public static let brandTeal = Color(red: 0.0, green: 0.78, blue: 0.75)
        public static let brandCyan = Color(red: 0.12, green: 0.84, blue: 0.90)
        public static let brandNavy = Color(red: 0.06, green: 0.09, blue: 0.16)
        public static let brandDarkSurface = Color(red: 0.09, green: 0.12, blue: 0.20)
        
        // MARK: - Feature Themes
        // Motor Health: Energizing, vibrant cyan/blue tones
        public static let motorPrimary = Color(red: 0.15, green: 0.62, blue: 0.95)
        public static let motorSecondary = Color(red: 0.36, green: 0.45, blue: 0.96)
        
        // MindEase: Calming sage and lavender tones
        public static let mindEasePrimary = Color(red: 0.30, green: 0.78, blue: 0.66)
        public static let mindEaseSecondary = Color(red: 0.58, green: 0.52, blue: 0.90)
        
        // MARK: - Functional Colors
        public static let success = Color(red: 0.22, green: 0.78, blue: 0.46)
        public static let warning = Color(red: 0.98, green: 0.65, blue: 0.20)
        public static let info = Color(red: 0.25, green: 0.65, blue: 0.96)
        
        // MARK: - Dynamic Surfaces
        public static var surfaceBackground: Color {
            Color(UIColor { trait in
                trait.userInterfaceStyle == .dark
                    ? UIColor(red: 0.06, green: 0.09, blue: 0.16, alpha: 1.0)
                    : UIColor(red: 0.97, green: 0.98, blue: 1.0, alpha: 1.0)
            })
        }
        
        public static var cardBackground: Color {
            Color(UIColor { trait in
                trait.userInterfaceStyle == .dark
                    ? UIColor(red: 0.11, green: 0.15, blue: 0.24, alpha: 1.0)
                    : UIColor(white: 1.0, alpha: 1.0)
            })
        }
        
        public static var subtleBorder: Color {
            Color(UIColor { trait in
                trait.userInterfaceStyle == .dark
                    ? UIColor(white: 1.0, alpha: 0.10)
                    : UIColor(red: 0.84, green: 0.88, blue: 0.94, alpha: 0.8)
            })
        }
    }
}
