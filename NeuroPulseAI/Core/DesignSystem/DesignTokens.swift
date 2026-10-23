//
//  DesignTokens.swift
//  NeuroPulseAI
//
//  Design system spacing, corner radii, and elevation constants.
//

import SwiftUI

public enum DesignTokens {
    public enum Spacing {
        public static let xSmall: CGFloat = 4
        public static let small: CGFloat = 8
        public static let medium: CGFloat = 16
        public static let large: CGFloat = 24
        public static let xLarge: CGFloat = 32
        public static let xxLarge: CGFloat = 40
    }
    
    public enum Radius {
        public static let small: CGFloat = 8
        public static let medium: CGFloat = 12
        public static let card: CGFloat = 20
        public static let pill: CGFloat = 999
    }
    
    public enum Shadow {
        public static let cardElevation: (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) = (
            Color.black.opacity(0.08), 12, 0, 4
        )
    }
}
