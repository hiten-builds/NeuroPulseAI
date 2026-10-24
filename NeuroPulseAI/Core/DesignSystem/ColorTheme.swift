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
        public static let error = Color(red: 0.95, green: 0.32, blue: 0.32)
        public static let info = Color(red: 0.25, green: 0.65, blue: 0.96)
        
        // MARK: - Dynamic Surfaces
        public static var surfaceBackground: Color {
            Color.white
        }
        
        public static var cardBackground: Color {
            Color.white
        }
        
        public static var subtleBorder: Color {
            Color.NeoBrutal.ink
        }
    }
}
