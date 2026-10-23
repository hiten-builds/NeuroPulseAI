//
//  DisclaimerBanner.swift
//  NeuroPulseAI
//
//  Medical non-diagnostic disclosure banner adhering to safety guidelines.
//

import SwiftUI

public struct DisclaimerBanner: View {
    public init() {}
    
    public var body: some View {
        HStack(alignment: .top, spacing: DesignTokens.Spacing.medium) {
            Image(systemName: "hand.raised.shield.fill")
                .font(.system(size: 20))
                .foregroundStyle(Color.NeuroPulse.info)
                .accessibilityHidden(true)
            
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xSmall) {
                Text("Non-Diagnostic Wellness Tool")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                
                Text("NeuroPulse AI measures motor interaction characteristics and provides mindful wellness tools. It does not provide medical diagnoses, treatment changes, or replace clinical care.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(DesignTokens.Spacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.NeuroPulse.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.medium))
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.Radius.medium)
                .stroke(Color.NeuroPulse.subtleBorder, lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Non-diagnostic disclosure: NeuroPulse AI measures motor interaction characteristics and provides mindful wellness tools. It does not provide medical diagnoses or replace clinical care.")
    }
}

#Preview {
    DisclaimerBanner()
        .padding()
}
