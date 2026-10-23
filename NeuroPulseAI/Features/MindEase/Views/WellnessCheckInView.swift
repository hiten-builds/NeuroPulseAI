//
//  WellnessCheckInView.swift
//  NeuroPulseAI
//
//  Optional, skippable self-reported relaxation check-in.
//

import SwiftUI

public struct WellnessCheckInView: View {
    let title: String
    let prompt: String
    let onRatingSelected: (Int?) -> Void
    
    @State private var selectedRating: Int? = nil
    
    public init(
        title: String = "Relaxation Check-In",
        prompt: String = "How calm and relaxed do you feel right now?",
        onRatingSelected: @escaping (Int?) -> Void
    ) {
        self.title = title
        self.prompt = prompt
        self.onRatingSelected = onRatingSelected
    }
    
    private let ratingLevels = [
        (1, "Tense", "cloud.rain.fill"),
        (2, "Restless", "wind"),
        (3, "Steady", "equal.circle"),
        (4, "Calm", "leaf.fill"),
        (5, "Deeply Relaxed", "sparkles")
    ]
    
    public var body: some View {
        VStack(spacing: DesignTokens.Spacing.large) {
            Spacer()
            
            VStack(spacing: DesignTokens.Spacing.small) {
                Image(systemName: "heart.text.square.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(Color.NeuroPulse.mindEasePrimary)
                
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                
                Text(prompt)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DesignTokens.Spacing.large)
            }
            
            // Rating Scale Selector (1-5)
            VStack(spacing: DesignTokens.Spacing.medium) {
                HStack(spacing: DesignTokens.Spacing.medium) {
                    ForEach(ratingLevels, id: \.0) { level in
                        Button {
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                                selectedRating = level.0
                            }
                        } label: {
                            VStack(spacing: DesignTokens.Spacing.small) {
                                ZStack {
                                    Circle()
                                        .fill(
                                            selectedRating == level.0
                                                ? Color.NeuroPulse.mindEasePrimary
                                                : Color.primary.opacity(0.06)
                                        )
                                        .frame(width: 52, height: 52)
                                    
                                    Image(systemName: level.2)
                                        .font(.system(size: 20))
                                        .foregroundStyle(
                                            selectedRating == level.0 ? .white : .primary
                                        )
                                }
                                
                                Text("\(level.0)")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundStyle(
                                        selectedRating == level.0 ? Color.NeuroPulse.mindEasePrimary : .secondary
                                    )
                                
                                Text(level.1)
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.7)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .padding(DesignTokens.Spacing.medium)
            .background(Color.NeuroPulse.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.card))
            .overlay(
                RoundedRectangle(cornerRadius: DesignTokens.Radius.card)
                    .stroke(Color.NeuroPulse.subtleBorder, lineWidth: 1)
            )
            .padding(.horizontal, DesignTokens.Spacing.large)
            
            Spacer()
            
            // Action Buttons
            VStack(spacing: DesignTokens.Spacing.small) {
                Button {
                    onRatingSelected(selectedRating)
                } label: {
                    Text(selectedRating != nil ? "Continue" : "Select a Rating")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DesignTokens.Spacing.medium)
                        .background(
                            selectedRating != nil ? Color.NeuroPulse.mindEasePrimary : Color.secondary.opacity(0.3)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.medium))
                }
                .disabled(selectedRating == nil)
                
                Button("Skip for Now") {
                    onRatingSelected(nil)
                }
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(.top, DesignTokens.Spacing.xSmall)
            }
            .padding(.horizontal, DesignTokens.Spacing.large)
            .padding(.bottom, DesignTokens.Spacing.large)
        }
        .background(Color.NeuroPulse.surfaceBackground.ignoresSafeArea())
    }
}

#Preview {
    WellnessCheckInView { _ in }
}
