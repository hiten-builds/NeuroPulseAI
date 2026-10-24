//
//  BreathingSessionView.swift
//  NeuroPulseAI
//
//  Guided paced breathing exercise with visual cues and optional check-in feedback.
//

import SwiftUI

public struct BreathingSessionView: View {
    @Environment(\.dismiss) private var dismiss
    
    public enum SessionStep {
        case preCheckIn
        case breathing
        case postCheckIn
        case completed
    }
    
    public enum BreathPhase: String {
        case inhale = "Inhale slowly..."
        case holdIn = "Hold gently..."
        case exhale = "Exhale smoothly..."
        case rest = "Rest..."
        
        var duration: Double {
            switch self {
            case .inhale: return 4.0
            case .holdIn: return 2.0
            case .exhale: return 4.0
            case .rest: return 2.0
            }
        }
    }
    
    @State private var currentStep: SessionStep = .preCheckIn
    @State private var phase: BreathPhase = .inhale
    @State private var circleScale: CGFloat = 0.75
    @State private var phaseSecondsRemaining: Double = 4.0
    @State private var totalSessionSeconds: Double = 60.0
    @State private var elapsedSeconds: Double = 0.0
    @State private var isRunning: Bool = false
    @State private var timer: Timer? = nil
    
    // Ratings
    @State private var ratingBefore: Int? = nil
    @State private var ratingAfter: Int? = nil
    
    @Environment(\.scenePhase) private var scenePhase
    @State private var hasSaved: Bool = false
    
    public init() {}
    
    public var body: some View {
        ZStack {
            Color.NeuroPulse.surfaceBackground.ignoresSafeArea()
            
            switch currentStep {
            case .preCheckIn:
                WellnessCheckInView(
                    title: "Before Breathing",
                    prompt: "How relaxed do you feel right now? (Optional)"
                ) { rating in
                    self.ratingBefore = rating
                    self.currentStep = .breathing
                    startBreathingExercise()
                }
            case .breathing:
                activeBreathingView
            case .postCheckIn:
                WellnessCheckInView(
                    title: "Session Complete",
                    prompt: "How relaxed do you feel now? (Optional)"
                ) { rating in
                    self.ratingAfter = rating
                    saveSession()
                    self.currentStep = .completed
                }
            case .completed:
                sessionSummaryView
            }
        }
        .navigationTitle("Guided Breathing")
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
    
    // MARK: - Active Breathing Interface
    
    private var activeBreathingView: some View {
        VStack(spacing: DesignTokens.Spacing.large) {
            // Header Progress
            HStack {
                Text(phase.rawValue)
                    .font(.headline)
                    .foregroundStyle(Color.NeuroPulse.mindEasePrimary)
                
                Spacer()
                
                let remaining = max(0, totalSessionSeconds - elapsedSeconds)
                Text(String(format: "%02d:%02d", Int(remaining) / 60, Int(remaining) % 60))
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, DesignTokens.Spacing.large)
            .padding(.top, DesignTokens.Spacing.medium)
            
            Spacer()
            
            // Visual Breathing Circle Pacer
            ZStack {
                // Ambient Outer Glow Aura
                Circle()
                    .fill(Color.NeuroPulse.mindEasePrimary.opacity(0.12))
                    .frame(width: 260, height: 260)
                    .scaleEffect(circleScale * 1.15)
                
                // Secondary Pulse Ring
                Circle()
                    .stroke(Color.NeuroPulse.mindEasePrimary.opacity(0.35), lineWidth: 3)
                    .frame(width: 200, height: 200)
                    .scaleEffect(circleScale * 1.05)
                
                // Core Breathing Bubble
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.NeuroPulse.mindEasePrimary, Color.NeuroPulse.mindEaseSecondary],
                            center: .center,
                            startRadius: 20,
                            endRadius: 100
                        )
                    )
                    .frame(width: 170, height: 170)
                    .scaleEffect(circleScale)
                    .shadow(color: Color.NeuroPulse.mindEasePrimary.opacity(0.4), radius: 20, x: 0, y: 10)
                
                // Center Phase Label
                VStack(spacing: 4) {
                    Text(phaseNameShort)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                    
                    Text(String(format: "%.0fs", phaseSecondsRemaining))
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white.opacity(0.8))
                }
            }
            
            Spacer()
            
            // Session Controls
            VStack(spacing: DesignTokens.Spacing.medium) {
                Button {
                    togglePause()
                } label: {
                    HStack(spacing: DesignTokens.Spacing.small) {
                        Image(systemName: isRunning ? "pause.fill" : "play.fill")
                        Text(isRunning ? "Pause" : "Resume")
                    }
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color.NeuroPulse.mindEasePrimary)
                    .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.medium))
                }
                
                Button("End Session Early", role: .cancel) {
                    endSessionEarly()
                }
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.secondary)
            }
            .padding(.horizontal, DesignTokens.Spacing.large)
            .padding(.bottom, DesignTokens.Spacing.large)
        }
    }
    
    // MARK: - Completed Summary View
    
    private var sessionSummaryView: some View {
        VStack(spacing: DesignTokens.Spacing.large) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.NeuroPulse.mindEasePrimary.opacity(0.15))
                    .frame(width: 90, height: 90)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(Color.NeuroPulse.mindEasePrimary)
            }
            
            VStack(spacing: DesignTokens.Spacing.small) {
                Text("Peaceful Moment Complete")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                
                Text("You took \(Int(elapsedSeconds)) seconds to pause, breathe, and center yourself.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DesignTokens.Spacing.large)
            }
            
            if let before = ratingBefore, let after = ratingAfter {
                HStack(spacing: DesignTokens.Spacing.large) {
                    VStack {
                        Text("Before")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        Text("\(before) / 5")
                            .font(.title3)
                            .fontWeight(.bold)
                    }
                    
                    Image(systemName: "arrow.right")
                        .foregroundStyle(Color.NeuroPulse.mindEasePrimary)
                    
                    VStack {
                        Text("After")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        Text("\(after) / 5")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.NeuroPulse.mindEasePrimary)
                    }
                }
                .padding(DesignTokens.Spacing.medium)
                .background(Color.NeuroPulse.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.medium))
                .overlay(
                    RoundedRectangle(cornerRadius: DesignTokens.Radius.medium)
                        .stroke(Color.NeuroPulse.subtleBorder, lineWidth: 0.75)
                )
            }
            
            Spacer()
            
            Button("Done") {
                dismiss()
            }
            .font(.system(size: 17, weight: .semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(Color.NeuroPulse.mindEasePrimary)
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.medium))
            .padding(.horizontal, DesignTokens.Spacing.large)
            .padding(.bottom, DesignTokens.Spacing.large)
        }
    }
    
    // MARK: - Logic & Animation
    
    private var phaseNameShort: String {
        switch phase {
        case .inhale: return "Inhale"
        case .holdIn: return "Hold"
        case .exhale: return "Exhale"
        case .rest: return "Rest"
        }
    }
    
    private func startBreathingExercise() {
        isRunning = true
        elapsedSeconds = 0.0
        transitionTo(phase: .inhale)
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { t in
            guard isRunning else { return }
            
            elapsedSeconds += 0.1
            phaseSecondsRemaining = max(0, phaseSecondsRemaining - 0.1)
            
            if phaseSecondsRemaining <= 0 {
                advancePhase()
            }
            
            if elapsedSeconds >= totalSessionSeconds {
                t.invalidate()
                timer = nil
                currentStep = .postCheckIn
            }
        }
    }
    
    private func advancePhase() {
        switch phase {
        case .inhale:
            transitionTo(phase: .holdIn)
        case .holdIn:
            transitionTo(phase: .exhale)
        case .exhale:
            transitionTo(phase: .rest)
        case .rest:
            transitionTo(phase: .inhale)
        }
    }
    
    private func transitionTo(phase: BreathPhase) {
        self.phase = phase
        self.phaseSecondsRemaining = phase.duration
        
        withAnimation(.easeInOut(duration: phase.duration)) {
            switch phase {
            case .inhale:
                circleScale = 1.35
            case .holdIn:
                circleScale = 1.35
            case .exhale:
                circleScale = 0.75
            case .rest:
                circleScale = 0.75
            }
        }
    }
    
    private func togglePause() {
        isRunning.toggle()
    }
    
    private func endSessionEarly() {
        stopTimer()
        saveSession(status: "Interrupted Early")
        currentStep = .completed
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        isRunning = false
    }
    
    private func saveSession(status: String = "Completed") {
        guard !hasSaved else { return }
        hasSaved = true
        let session = WellnessSessionRecord(
            accountID: AuthManager.shared.currentUser?.id,
            activityType: .breathing,
            durationSeconds: elapsedSeconds,
            completionStatus: status,
            ratingBefore: ratingBefore,
            ratingAfter: ratingAfter
        )
        WellnessSessionStore.shared.save(record: session)
    }
}

#Preview {
    NavigationStack {
        BreathingSessionView()
    }
}
