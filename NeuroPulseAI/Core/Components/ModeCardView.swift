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
        category: String,
        subtitle: String,
        iconName: String,
        gradientColors: [Color],
        features: [String]
    ) {
        self.title = title
        self.category = category
        self.subtitle = subtitle
        self.iconName = iconName
        self.gradientColors = gradientColors
        self.features = features
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.medium) {
            // Header Row: Category Badge & Icon
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xSmall) {
                    Text(category.uppercased())
                        .font(.caption2)
                        .fontWeight(.bold)
                        .tracking(1.2)
                        .foregroundStyle(gradientColors.first ?? Color.NeuroPulse.brandTeal)
                        .padding(.horizontal, DesignTokens.Spacing.small)
                        .padding(.vertical, DesignTokens.Spacing.xSmall)
                        .background(
                            Capsule()
                                .fill((gradientColors.first ?? Color.NeuroPulse.brandTeal).opacity(0.15))
                        )
                    
                    Text(title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                }
                
                Spacer()
                
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
                            color: (gradientColors.first ?? .clear).opacity(0.35),
                            radius: 8,
                            x: 0,
                            y: 4
                        )
                    
                    Image(systemName: iconName)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(.white)
                }
            }
            
            // Subtitle Description
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            
            // Feature Tags
            HStack(spacing: DesignTokens.Spacing.small) {
                ForEach(features, id: \.self) { feature in
                    Text(feature)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, DesignTokens.Spacing.small)
                        .padding(.vertical, DesignTokens.Spacing.xSmall)
                        .background(
                            Capsule()
                                .fill(Color.primary.opacity(0.05))
                        )
                }
            }
            
            // Action prompt row
            HStack {
                Text("Open Experience")
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundStyle(gradientColors.first ?? Color.NeuroPulse.brandTeal)
                
                Image(systemName: "arrow.right.circle.fill")
                    .font(.footnote)
                    .foregroundStyle(gradientColors.first ?? Color.NeuroPulse.brandTeal)
            }
            .padding(.top, DesignTokens.Spacing.xSmall)
        }
        .padding(DesignTokens.Spacing.large)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.NeuroPulse.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.card))
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.Radius.card)
                .stroke(Color.NeuroPulse.subtleBorder, lineWidth: 1)
        )
        .shadow(
            color: DesignTokens.Shadow.cardElevation.color,
            radius: DesignTokens.Shadow.cardElevation.radius,
            x: DesignTokens.Shadow.cardElevation.x,
            y: DesignTokens.Shadow.cardElevation.y
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(category): \(title). \(subtitle). Features include \(features.joined(separator: ", ")).")
        .accessibilityHint("Double tap to enter \(title)")
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
