//
//  ModeCardView.swift
//  NeuroPulseAI
//
//  Interactive mode selection card with dynamic styling and accessibility support.
//

import SwiftUI

public struct ModeCardView: View {
    let title: String
    let category: String
    let subtitle: String
    let iconName: String
    let gradientColors: [Color]
    let features: [String]
    
    public init(
        title: String,
        category: String = "",
        subtitle: String = "",
        iconName: String,
        gradientColors: [Color],
        features: [String] = []
    ) {
        self.title = title
        self.category = category
        self.subtitle = subtitle
        self.iconName = iconName
        self.gradientColors = gradientColors
        self.features = features
    }
    
    public var body: some View {
        HStack(spacing: 16) {
            // Icon Emblem with Soft Ambient Glow
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: gradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 48, height: 48)
                    .shadow(
                        color: (gradientColors.first ?? .clear).opacity(0.20),
                        radius: 6,
                        x: 0,
                        y: 3
                    )
                
                Image(systemName: iconName)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
            }
            
            Text(title)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.NeuroPulse.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.NeuroPulse.subtleBorder, lineWidth: 0.75)
        )
        .shadow(
            color: Color.black.opacity(0.03),
            radius: 8,
            x: 0,
            y: 2
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
        .accessibilityHint("Double tap to open \(title)")
    }
}

#Preview {
    VStack(spacing: 16) {
        ModeCardView(
            title: "Motor Health",
            category: "Assessment",
            subtitle: "Measure fine-motor control, tapping frequency, and tremor stability.",
            iconName: "hand.tap.fill",
            gradientColors: [Color.NeuroPulse.motorPrimary, Color.NeuroPulse.motorSecondary],
            features: ["Finger Tapping", "Spiral Tracing"]
        )
        
        ModeCardView(
            title: "MindEase",
            category: "Wellness",
            subtitle: "Guided breathing, mindfulness, and relaxation check-ins.",
            iconName: "wind",
            gradientColors: [Color.NeuroPulse.mindEasePrimary, Color.NeuroPulse.mindEaseSecondary],
            features: ["Guided Breathing", "Mindfulness", "Check-ins"]
        )
    }
    .padding()
}
