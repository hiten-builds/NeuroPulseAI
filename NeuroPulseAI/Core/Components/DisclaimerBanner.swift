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
        HStack(alignment: .top, spacing: DesignTokens.Spacing.small) {
            Image(systemName: "shield.lefthalf.filled")
                .font(.system(size: 18))
                .foregroundStyle(Color.NeuroPulse.info)
                .accessibilityHidden(true)
                .padding(.top, 1)
            
            VStack(alignment: .leading, spacing: 3) {
                Text("Non-Diagnostic Wellness Tool")
                    .font(.footnote)
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
        .background(Color.NeuroPulse.cardBackground.opacity(0.85))
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.medium))
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.Radius.medium)
                .stroke(Color.NeuroPulse.subtleBorder, lineWidth: 0.75)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Non-diagnostic disclosure: NeuroPulse AI measures motor interaction characteristics and provides mindful wellness tools. It does not provide medical diagnoses or replace clinical care.")
    }
}

#Preview {
    DisclaimerBanner()
        .padding()
}
