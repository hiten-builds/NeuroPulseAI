//
//  TappingTestView.swift
//  NeuroPulseAI
//
//  Interactive finger-tapping assessment capturing touch events with monotonic timestamps.
//

import SwiftUI

public struct TappingTestView: View {
    @Environment(\.dismiss) private var dismiss
    
    public enum TestState {
        case instructions
        case countdown(Int)
        case active
        case finished(TappingMetrics)
    }
    
    @State private var state: TestState = .instructions
    @State private var selectedHand: String = "Right"
    @State private var plannedDuration: TimeInterval = 15.0
    
    // Test recording state
    @State private var startNanos: UInt64 = 0
    @State private var events: [TapEvent] = []
    @State private var currentElapsed: TimeInterval = 0.0
    @State private var recordingTimer: Timer? = nil
    @State private var countdownTimer: Timer? = nil
    
    // Animation states
    @State private var tapScale: CGFloat = 1.0
    
    public init() {}
    
    public var body: some View {
        ZStack {
            Color.NeuroPulse.surfaceBackground.ignoresSafeArea()
            
            switch state {
            case .instructions:
                instructionsView
            case .countdown(let count):
                countdownView(count: count)
            case .active:
                activeTestView
            case .finished(let metrics):
                TappingResultView(metrics: metrics) {
                    dismiss()
                }
            }
        }
        .navigationTitle("Finger Tapping")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if case .instructions = state {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .onDisappear {
            cleanupTimers()
        }
    }
    
    // MARK: - Instructions View
    
    private var instructionsView: some View {
        VStack(spacing: DesignTokens.Spacing.large) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.NeuroPulse.motorPrimary.opacity(0.12))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "hand.point.up.left.fill")
                    .font(.system(size: 46))
                    .foregroundStyle(Color.NeuroPulse.motorPrimary)
            }
            
            VStack(spacing: DesignTokens.Spacing.small) {
                Text("Finger-Tapping Test")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                
                Text("Tap the target as rapidly and steadily as you can using your index finger. Keep tapping until the timer completes.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DesignTokens.Spacing.large)
            }
            
            // Hand Selection Picker
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.small) {
                Text("Select Hand")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                
                Picker("Tested Hand", selection: $selectedHand) {
                    Text("Right Hand").tag("Right")
                    Text("Left Hand").tag("Left")
                }
                .pickerStyle(.segmented)
            }
            .padding(.horizontal, DesignTokens.Spacing.large)
            
            // Protocol Notice
            HStack(spacing: DesignTokens.Spacing.small) {
                Image(systemName: "timer")
                    .foregroundStyle(Color.NeuroPulse.motorPrimary)
                Text("Protocol duration: \(Int(plannedDuration)) seconds")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Button {
                startCountdown()
            } label: {
                Text("Start Assessment")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DesignTokens.Spacing.medium)
                    .background(Color.NeuroPulse.motorPrimary)
                    .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.medium))
            }
            .padding(.horizontal, DesignTokens.Spacing.large)
            .padding(.bottom, DesignTokens.Spacing.large)
        }
    }
    
    // MARK: - Countdown View
    
    private func countdownView(count: Int) -> some View {
        VStack(spacing: DesignTokens.Spacing.large) {
            Text("Get Ready")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
            
            Text("\(count)")
                .font(.system(size: 96, weight: .heavy, design: .rounded))
                .foregroundStyle(Color.NeuroPulse.motorPrimary)
                .scaleEffect(tapScale)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: count)
            
            Text("Position your index finger")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
    
    // MARK: - Active Test View
    
    private var activeTestView: some View {
        VStack(spacing: DesignTokens.Spacing.large) {
            // Timer and Count Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("TIME REMAINING")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)
                    
                    let remaining = max(0.0, plannedDuration - currentElapsed)
                    Text(String(format: "%.1fs", remaining))
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.NeuroPulse.motorPrimary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("TAPS")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)
                    
                    Text("\(events.count)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                }
            }
            .padding(.horizontal, DesignTokens.Spacing.large)
            .padding(.top, DesignTokens.Spacing.medium)
            
            // Progress Bar Ring
            GeometryReader { geo in
                let progress = min(1.0, currentElapsed / plannedDuration)
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.primary.opacity(0.08))
                        .frame(height: 8)
                    
                    Capsule()
                        .fill(Color.NeuroPulse.motorPrimary)
                        .frame(width: geo.size.width * CGFloat(progress), height: 8)
                }
            }
            .frame(height: 8)
            .padding(.horizontal, DesignTokens.Spacing.large)
            
            Spacer()
            
            // Main Tap Target Button
            Button {
                recordTap()
            } label: {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.NeuroPulse.motorPrimary, Color.NeuroPulse.motorSecondary],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 220, height: 220)
                        .shadow(color: Color.NeuroPulse.motorPrimary.opacity(0.35), radius: 20, x: 0, y: 10)
                        .scaleEffect(tapScale)
                    
                    VStack(spacing: DesignTokens.Spacing.small) {
                        Image(systemName: "hand.tap.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(.white)
                        
                        Text("TAP HERE")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
            
            // Cancel Button
            Button("Cancel Test", role: .cancel) {
                cancelTest()
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
            .padding(.bottom, DesignTokens.Spacing.large)
        }
    }
    
    // MARK: - Logic & Monotonic Timing
    
    private func startCountdown() {
        cleanupTimers()
        state = .countdown(3)
        var count = 3
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 0.9, repeats: true) { cTimer in
            count -= 1
            if count > 0 {
                state = .countdown(count)
            } else {
                cTimer.invalidate()
                countdownTimer = nil
                beginRecording()
            }
        }
    }
    
    private func beginRecording() {
        cleanupTimers()
        events = []
        currentElapsed = 0.0
        startNanos = MonotonicClock.nowNanoseconds()
        state = .active
        
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { t in
            let elapsed = getMonotonicElapsedSeconds()
            currentElapsed = elapsed
            
            if elapsed >= plannedDuration {
                t.invalidate()
                recordingTimer = nil
                finishTest()
            }
        }
    }
    
    private func recordTap() {
        guard case .active = state else { return }
        let elapsed = getMonotonicElapsedSeconds()
        let event = TapEvent(elapsedSeconds: elapsed, target: .primary)
        events.append(event)
        
        // Haptic feedback & tap animation
        withAnimation(.spring(response: 0.12, dampingFraction: 0.5)) {
            tapScale = 0.92
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            withAnimation(.spring(response: 0.15, dampingFraction: 0.6)) {
                tapScale = 1.0
            }
        }
    }
    
    private func getMonotonicElapsedSeconds() -> TimeInterval {
        guard startNanos > 0 else { return 0.0 }
        return MonotonicClock.elapsedSeconds(since: startNanos)
    }
    
    private func finishTest() {
        cleanupTimers()
        let finalElapsed = getMonotonicElapsedSeconds()
        let metrics = MotorFeatureCalculator.calculateMetrics(
            events: events,
            plannedDuration: plannedDuration,
            actualDuration: finalElapsed,
            testedHand: selectedHand
        )
        let session = MotorSessionRecord(
            date: Date(),
            testType: .tapping,
            testedHand: selectedHand,
            durationSeconds: finalElapsed,
            primaryScoreLabel: String(format: "%.1f Hz", metrics.cadenceHz),
            primaryScoreValue: metrics.cadenceHz,
            secondaryScoreLabel: "\(metrics.tapCount) taps",
            qualityStatus: metrics.qualityStatus,
            protocolVersion: metrics.protocolVersion,
            isSampleData: false
        )
        MotorSessionStore.shared.save(record: session)
        state = .finished(metrics)
    }
    
    private func cancelTest() {
        cleanupTimers()
        dismiss()
    }
    
    private func cleanupTimers() {
        countdownTimer?.invalidate()
        countdownTimer = nil
        recordingTimer?.invalidate()
        recordingTimer = nil
    }
}

#Preview {
    NavigationStack {
        TappingTestView()
    }
}
