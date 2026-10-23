//
//  MindfulnessMeditationView.swift
//  NeuroPulseAI
//
//  Quiet, self-directed mindfulness meditation pause with ambient visual cues.
//

import SwiftUI

public struct MindfulnessMeditationView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var selectedMinutes: Int = 3
    @State private var isRunning: Bool = false
    @State private var elapsedSeconds: Double = 0.0
    @State private var reflectionIndex: Int = 0
    @State private var timer: Timer? = nil
    @State private var auraScale: CGFloat = 1.0
    @State private var hasSaved: Bool = false
    
    private let reflections = [
        "Notice the sensation of your natural breath.",
        "Release any tension held in your shoulders and jaw.",
        "Let thoughts pass like clouds across an open sky.",
        "Anchor your attention gently in the present moment.",
        "Rest in quiet awareness with no need to strive."
    ]
    
    public init() {}
    
    private var totalSeconds: Double {
        Double(selectedMinutes * 60)
    }
    
    public var body: some View {
        VStack(spacing: DesignTokens.Spacing.large) {
            // Header timer
            HStack {
                Text(isRunning ? "Mindfulness Pause" : "Prepare for Meditation")
                    .font(.headline)
                    .foregroundStyle(Color.NeuroPulse.mindEaseSecondary)
                
                Spacer()
                
                let remaining = max(0, totalSeconds - elapsedSeconds)
                Text(String(format: "%02d:%02d", Int(remaining) / 60, Int(remaining) % 60))
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, DesignTokens.Spacing.large)
            .padding(.top, DesignTokens.Spacing.medium)
            
            if !isRunning && elapsedSeconds == 0 {
                durationSelectorView
            }
            
            Spacer()
            
            // Central Pulsing Mandala Aura
            ZStack {
                Circle()
                    .fill(Color.NeuroPulse.mindEaseSecondary.opacity(0.10))
                    .frame(width: 250, height: 250)
                    .scaleEffect(auraScale * 1.1)
                
                Circle()
                    .fill(Color.NeuroPulse.mindEaseSecondary.opacity(0.18))
                    .frame(width: 190, height: 190)
                    .scaleEffect(auraScale)
                
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.NeuroPulse.mindEaseSecondary, Color.NeuroPulse.brandNavy],
                            center: .center,
                            startRadius: 10,
                            endRadius: 80
                        )
                    )
                    .frame(width: 120, height: 120)
                    .shadow(color: Color.NeuroPulse.mindEaseSecondary.opacity(0.35), radius: 16, x: 0, y: 6)
                
                Image(systemName: "sparkles")
                    .font(.system(size: 36))
                    .foregroundStyle(.white)
            }
            
            Spacer()
            
            // Mindful Guidance Text
            Text(reflections[reflectionIndex])
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, DesignTokens.Spacing.large)
                .frame(height: 50)
                .animation(.easeInOut(duration: 0.5), value: reflectionIndex)
            
            // Controls
            VStack(spacing: DesignTokens.Spacing.medium) {
                if !isRunning && elapsedSeconds == 0 {
                    Button {
                        startSession()
                    } label: {
                        Text("Begin Meditation")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, DesignTokens.Spacing.medium)
                            .background(Color.NeuroPulse.mindEaseSecondary)
                            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.medium))
                    }
                } else {
                    Button {
                        togglePause()
                    } label: {
                        HStack(spacing: DesignTokens.Spacing.small) {
                            Image(systemName: isRunning ? "pause.fill" : "play.fill")
                            Text(isRunning ? "Pause" : "Resume")
                        }
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DesignTokens.Spacing.medium)
                        .background(Color.NeuroPulse.mindEaseSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.medium))
                    }
                    
                    Button("End Session", role: .cancel) {
                        finishSession()
                    }
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, DesignTokens.Spacing.large)
            .padding(.bottom, DesignTokens.Spacing.large)
        }
        .background(Color.NeuroPulse.surfaceBackground.ignoresSafeArea())
        .navigationTitle("Mindfulness Pause")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            stopTimer()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .background && isRunning {
                isRunning = false
            }
        }
    }
    
    private var durationSelectorView: some View {
        HStack(spacing: DesignTokens.Spacing.medium) {
            ForEach([1, 3, 5], id: \.self) { min in
                Button {
                    selectedMinutes = min
                } label: {
                    Text("\(min) min")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(selectedMinutes == min ? .white : .primary)
                        .padding(.horizontal, DesignTokens.Spacing.medium)
                        .padding(.vertical, DesignTokens.Spacing.small)
                        .background(
                            selectedMinutes == min ? Color.NeuroPulse.mindEaseSecondary : Color.primary.opacity(0.06)
                        )
                        .clipShape(Capsule())
                }
            }
        }
    }
    
    private func startSession() {
        stopTimer()
        isRunning = true
        elapsedSeconds = 0.0
        startAuraPulse()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { t in
            guard isRunning else { return }
            elapsedSeconds += 0.2
            
            // Advance reflection prompt every 12 seconds
            let newIndex = (Int(elapsedSeconds) / 12) % reflections.count
            if newIndex != reflectionIndex {
                reflectionIndex = newIndex
            }
            
            if elapsedSeconds >= totalSeconds {
                t.invalidate()
                timer = nil
                finishSession()
            }
        }
    }
    
    private func startAuraPulse() {
        withAnimation(.easeInOut(duration: 3.5).repeatForever(autoreverses: true)) {
            auraScale = 1.15
        }
    }
    
    private func togglePause() {
        isRunning.toggle()
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        isRunning = false
    }
    
    private func finishSession() {
        stopTimer()
        guard !hasSaved else {
            dismiss()
            return
        }
        hasSaved = true
        let record = WellnessSessionRecord(
            accountID: AuthManager.shared.currentUser?.id,
            activityType: .meditation,
            durationSeconds: elapsedSeconds,
            completionStatus: elapsedSeconds >= totalSeconds ? "Completed" : "Self-Directed"
        )
        WellnessSessionStore.shared.save(record: record)
        dismiss()
    }
}

#Preview {
    NavigationStack {
        MindfulnessMeditationView()
    }
}
