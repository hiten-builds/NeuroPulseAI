//
//  MindfulTracingView.swift
//  NeuroPulseAI
//
//  Unscored tactile grounding exercise for gentle focus and relaxation.
//

import SwiftUI

public struct MindfulTracingView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentPath: [CGPoint] = []
    @State private var completedPaths: [[CGPoint]] = []
    @State private var startTimestamp = Date()
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: DesignTokens.Spacing.medium) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.NeuroPulse.brandTeal)
                            .frame(width: 8, height: 8)
                        Text("Unscored Wellness")
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.NeuroPulse.brandTeal)
                    }
                    
                    Text("Flow with your finger freely")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Button("Clear") {
                    completedPaths.removeAll()
                    currentPath.removeAll()
                }
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.secondary)
            }
            .padding(.horizontal, DesignTokens.Spacing.large)
            .padding(.top, DesignTokens.Spacing.small)
            
            // Drawing Surface
            GeometryReader { geo in
                ZStack {
                    RoundedRectangle(cornerRadius: DesignTokens.Radius.card)
                        .fill(Color.NeuroPulse.cardBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignTokens.Radius.card)
                                .stroke(Color.NeuroPulse.subtleBorder, lineWidth: 0.75)
                        )
                        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
                    
                    // Calming Ambient Prompt in background
                    if completedPaths.isEmpty && currentPath.isEmpty {
                        VStack(spacing: DesignTokens.Spacing.small) {
                            Image(systemName: "hand.draw.fill")
                                .font(.system(size: 40))
                                .foregroundStyle(Color.NeuroPulse.brandTeal.opacity(0.4))
                            
                            Text("Draw smooth shapes or waves at your own pace")
                                .font(.subheadline)
                                .foregroundStyle(.secondary.opacity(0.6))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, DesignTokens.Spacing.large)
                        }
                    }
                    
                    // Render Completed Paths
                    ForEach(0..<completedPaths.count, id: \.self) { idx in
                        let pts = completedPaths[idx]
                        Path { path in
                            guard let first = pts.first else { return }
                            path.move(to: first)
                            for p in pts.dropFirst() {
                                path.addLine(to: p)
                            }
                        }
                        .stroke(
                            LinearGradient(
                                colors: [Color.NeuroPulse.mindEasePrimary, Color.NeuroPulse.brandTeal],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round)
                        )
                    }
                    
                    // Render Current Active Path
                    if !currentPath.isEmpty {
                        Path { path in
                            guard let first = currentPath.first else { return }
                            path.move(to: first)
                            for p in currentPath.dropFirst() {
                                path.addLine(to: p)
                            }
                        }
                        .stroke(
                            LinearGradient(
                                colors: [Color.NeuroPulse.mindEasePrimary, Color.white],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round)
                        )
                    }
                }
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            currentPath.append(value.location)
                        }
                        .onEnded { _ in
                            if !currentPath.isEmpty {
                                completedPaths.append(currentPath)
                                currentPath.removeAll()
                            }
                        }
                )
            }
            .aspectRatio(1.0, contentMode: .fit)
            .padding(.horizontal, DesignTokens.Spacing.large)
            
            // Grounding Note
            HStack(spacing: DesignTokens.Spacing.small) {
                Image(systemName: "info.circle")
                    .foregroundStyle(Color.NeuroPulse.brandTeal)
                Text("This activity is purely for tactile relaxation and is not evaluated for motor performance.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, DesignTokens.Spacing.large)
            
            Spacer()
            
            // Finish Button
            Button {
                finishSession()
            } label: {
                Text("Finish Session")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color.NeuroPulse.brandTeal)
                    .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.medium))
            }
            .padding(.horizontal, DesignTokens.Spacing.large)
            .padding(.bottom, DesignTokens.Spacing.large)
        }
        .background(Color.NeuroPulse.surfaceBackground.ignoresSafeArea())
        .navigationTitle("Mindful Tracing")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func finishSession() {
        let duration = Date().timeIntervalSince(startTimestamp)
        let record = WellnessSessionRecord(
            accountID: AuthManager.shared.currentUser?.id,
            activityType: .mindfulTracing,
            durationSeconds: duration,
            completionStatus: "Completed"
        )
        WellnessSessionStore.shared.save(record: record)
        dismiss()
    }
}

#Preview {
    NavigationStack {
        MindfulTracingView()
    }
}
