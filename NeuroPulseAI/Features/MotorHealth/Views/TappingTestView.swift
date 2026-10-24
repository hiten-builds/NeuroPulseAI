//
//  TappingTestView.swift
//  NeuroPulseAI
//
//  Two-zone alternating finger-tapping assessment measuring motor cadence,
//  rhythm stability, and geometric center-deviation accuracy.
//

import SwiftUI
import CoreGraphics

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
    @State private var events: [TapEvent] = []
    
    // Configurable protocol durations
    private let plannedDuration: TimeInterval = 15.0
    
    // Monotonic clock references (nanoseconds)
    @State private var startNanos: UInt64 = 0
    @State private var currentElapsed: TimeInterval = 0.0
    @State private var lastTapElapsed: TimeInterval = 0.0
    
    // Active alternating protocol state
    @State private var expectedTarget: TapTarget = .left
    @State private var isContactActive: Bool = false
    @State private var leftFlashState: TargetFlashState = .none
    @State private var rightFlashState: TargetFlashState = .none
    
    // Timers
    @State private var countdownTimer: Timer? = nil
    @State private var recordingTimer: Timer? = nil
    
    private let targetDiameter: CGFloat = 64.0
    private let targetRadius: CGFloat = 32.0
    
    enum TargetFlashState {
        case none
        case success
        case error
    }
    
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
        .onDisappear {
            cleanupTimers()
        }
    }
    
    // MARK: - Instructions View
    
    private var instructionsView: some View {
        VStack(spacing: DesignTokens.Spacing.large) {
            ScrollView {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.large) {
                    // Title and Description
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.small) {
                        HStack(spacing: DesignTokens.Spacing.small) {
                            Circle()
                                .fill(Color.NeuroPulse.motorPrimary)
                                .frame(width: 8, height: 8)
                            Text("Two-Zone Alternating Protocol")
                                .font(.footnote)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.NeuroPulse.motorPrimary)
                        }
                        
                        Text("Alternating Finger Tapping")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)
                        
                        Text("Place your device flat on a stable surface. You will alternate tapping between two targets using your index finger as rapidly and precisely as possible.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    // Visual Preview of Two Targets
                    VStack(spacing: DesignTokens.Spacing.medium) {
                        Text("Target Layout Preview")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                        
                        HStack(spacing: 64) {
                            VStack(spacing: 6) {
                                ZStack {
                                    Circle()
                                        .fill(Color.NeuroPulse.motorPrimary.opacity(0.15))
                                        .frame(width: targetDiameter, height: targetDiameter)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.NeuroPulse.motorPrimary, lineWidth: 2)
                                        )
                                    Text("L")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundStyle(Color.NeuroPulse.motorPrimary)
                                }
                                Text("Left (Start)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Image(systemName: "arrow.left.and.right")
                                .font(.title3)
                                .foregroundStyle(.secondary)
                            
                            VStack(spacing: 6) {
                                ZStack {
                                    Circle()
                                        .fill(Color.NeuroPulse.cardBackground)
                                        .frame(width: targetDiameter, height: targetDiameter)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.NeuroPulse.subtleBorder, lineWidth: 1.5)
                                        )
                                    Text("R")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.secondary)
                                }
                                Text("Right")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, DesignTokens.Spacing.medium)
                        .frame(maxWidth: .infinity)
                        .background(Color.NeuroPulse.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.medium))
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignTokens.Radius.medium)
                                .stroke(Color.NeuroPulse.subtleBorder, lineWidth: 0.75)
                        )
                    }
                    
                    // Step Guidelines
                    VStack(spacing: DesignTokens.Spacing.medium) {
                        instructionRow(
                            number: "1",
                            title: "Start on the Left Target",
                            subtitle: "When the countdown finishes, tap the highlighted Left target first."
                        )
                        instructionRow(
                            number: "2",
                            title: "Alternate Between Targets",
                            subtitle: "After each hit, the highlight switches. Move quickly and aim for the center."
                        )
                        instructionRow(
                            number: "3",
                            title: "Target Center Precision",
                            subtitle: "The app calculates the distance in points from the exact center of each target."
                        )
                    }
                    
                    // Hand Selection
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.small) {
                        Text("Select Tested Hand")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                        
                        Picker("Tested Hand", selection: $selectedHand) {
                            Text("Right Hand").tag("Right")
                            Text("Left Hand").tag("Left")
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    // Duration Notice
                    HStack(spacing: DesignTokens.Spacing.small) {
                        Image(systemName: "timer")
                            .foregroundStyle(Color.NeuroPulse.motorPrimary)
                        Text("Assessment duration: \(Int(plannedDuration)) seconds")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, DesignTokens.Spacing.large)
                .padding(.top, DesignTokens.Spacing.small)
            }
            
            // Start Button
            Button {
                startCountdown()
            } label: {
                Text("Start Assessment")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
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
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: count)
            
            Text("Position index finger over Left target")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
    
    // MARK: - Active Test View (Two-Zone Alternating Interaction)
    
    private var activeTestView: some View {
        VStack(spacing: DesignTokens.Spacing.large) {
            // Header: Time & Alternating Counter
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Time Remaining")
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                    
                    let remaining = max(0.0, plannedDuration - currentElapsed)
                    Text(String(format: "%.1fs", remaining))
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.NeuroPulse.motorPrimary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Valid Taps")
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                    
                    let validCount = events.filter { $0.hitCategory == .correctTarget }.count
                    Text("\(validCount)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                }
            }
            .padding(.horizontal, DesignTokens.Spacing.large)
            .padding(.top, DesignTokens.Spacing.small)
            
            // Expected target instruction banner
            HStack(spacing: 8) {
                Image(systemName: expectedTarget == .left ? "arrow.left.circle.fill" : "arrow.right.circle.fill")
                    .foregroundStyle(Color.NeuroPulse.motorPrimary)
                Text("Tap the highlighted \(expectedTarget == .left ? "Left" : "Right") target")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, DesignTokens.Spacing.medium)
            .background(Color.NeuroPulse.cardBackground)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(Color.NeuroPulse.subtleBorder, lineWidth: 0.75)
            )
            
            Spacer()
            
            // Two-Zone Interactive Touch Area
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                
                let leftCenter = CGPoint(x: w * 0.28, y: h * 0.5)
                let rightCenter = CGPoint(x: w * 0.72, y: h * 0.5)
                
                ZStack {
                    // Background touch receiver plane
                    RoundedRectangle(cornerRadius: DesignTokens.Radius.card)
                        .fill(Color.NeuroPulse.cardBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignTokens.Radius.card)
                                .stroke(Color.NeuroPulse.subtleBorder, lineWidth: 0.75)
                        )
                    
                    // Left Target View
                    targetCircleView(
                        label: "L",
                        sublabel: "Left",
                        isExpected: expectedTarget == .left,
                        flashState: leftFlashState
                    )
                    .position(leftCenter)
                    
                    // Right Target View
                    targetCircleView(
                        label: "R",
                        sublabel: "Right",
                        isExpected: expectedTarget == .right,
                        flashState: rightFlashState
                    )
                    .position(rightCenter)
                }
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            guard !isContactActive else { return }
                            isContactActive = true
                            handleTap(
                                at: value.location,
                                leftCenter: leftCenter,
                                rightCenter: rightCenter,
                                radius: targetRadius
                            )
                        }
                        .onEnded { _ in
                            isContactActive = false
                        }
                )
            }
            .frame(height: 240)
            .padding(.horizontal, DesignTokens.Spacing.large)
            
            Spacer()
            
            // Cancel Assessment
            Button("Cancel Assessment", role: .cancel) {
                cancelTest()
            }
            .font(.system(size: 16, weight: .medium))
            .foregroundStyle(.secondary)
            .padding(.bottom, DesignTokens.Spacing.large)
        }
    }
    
    @ViewBuilder
    private func targetCircleView(
        label: String,
        sublabel: String,
        isExpected: Bool,
        flashState: TargetFlashState
    ) -> some View {
        VStack(spacing: 4) {
            ZStack {
                // Outer glow / active pulse
                if isExpected {
                    Circle()
                        .stroke(Color.NeuroPulse.motorPrimary.opacity(0.4), lineWidth: 8)
                        .frame(width: targetDiameter + 12, height: targetDiameter + 12)
                }
                
                // Target background
                Circle()
                    .fill(
                        flashState == .success ? Color.NeuroPulse.success.opacity(0.25) :
                        flashState == .error ? Color.NeuroPulse.warning.opacity(0.35) :
                        isExpected ? Color.NeuroPulse.motorPrimary.opacity(0.18) :
                        Color.primary.opacity(0.04)
                    )
                    .frame(width: targetDiameter, height: targetDiameter)
                
                // Target border
                Circle()
                    .stroke(
                        flashState == .success ? Color.NeuroPulse.success :
                        flashState == .error ? Color.NeuroPulse.warning :
                        isExpected ? Color.NeuroPulse.motorPrimary :
                        Color.primary.opacity(0.15),
                        lineWidth: isExpected ? 3.0 : 1.5
                    )
                    .frame(width: targetDiameter, height: targetDiameter)
                
                // Center precision crosshair indicator
                Circle()
                    .fill(isExpected ? Color.NeuroPulse.motorPrimary : Color.secondary.opacity(0.4))
                    .frame(width: 8, height: 8)
                
                Text(label)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(isExpected ? Color.NeuroPulse.motorPrimary : .secondary)
                    .offset(y: -16)
            }
            
            Text(sublabel)
                .font(.caption2)
                .fontWeight(isExpected ? .bold : .medium)
                .foregroundStyle(isExpected ? Color.NeuroPulse.motorPrimary : .secondary)
        }
    }
    
    // MARK: - Logic & Two-Zone Alternating Protocol
    
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
        lastTapElapsed = 0.0
        expectedTarget = .left
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
    
    private func handleTap(
        at location: CGPoint,
        leftCenter: CGPoint,
        rightCenter: CGPoint,
        radius: CGFloat
    ) {
        guard case .active = state else { return }
        
        let elapsed = getMonotonicElapsedSeconds()
        // Debounce micro-contacts (< 35ms)
        if elapsed - lastTapElapsed < 0.035 {
            return
        }
        lastTapElapsed = elapsed
        
        // Calculate distances to both targets
        let dxLeft = location.x - leftCenter.x
        let dyLeft = location.y - leftCenter.y
        let distLeft = sqrt(dxLeft * dxLeft + dyLeft * dyLeft)
        
        let dxRight = location.x - rightCenter.x
        let dyRight = location.y - rightCenter.y
        let distRight = sqrt(dxRight * dxRight + dyRight * dyRight)
        
        let isInsideLeft = distLeft <= radius
        let isInsideRight = distRight <= radius
        
        // Expected target geometry
        let expectedCenter = (expectedTarget == .left) ? leftCenter : rightCenter
        
        let hitCategory: TapHitCategory
        
        if expectedTarget == .left {
            if isInsideLeft {
                hitCategory = .correctTarget
                // Advance protocol: switch to right
                expectedTarget = .right
                flashTarget(.left, state: .success)
            } else if isInsideRight {
                hitCategory = .wrongTarget
                // Retain expected target (.left) so user can try again
                flashTarget(.right, state: .error)
            } else {
                hitCategory = .outsideBoth
                flashTarget(.left, state: .error)
            }
        } else { // expectedTarget == .right
            if isInsideRight {
                hitCategory = .correctTarget
                // Advance protocol: switch to left
                expectedTarget = .left
                flashTarget(.right, state: .success)
            } else if isInsideLeft {
                hitCategory = .wrongTarget
                // Retain expected target (.right) so user can try again
                flashTarget(.left, state: .error)
            } else {
                hitCategory = .outsideBoth
                flashTarget(.right, state: .error)
            }
        }
        
        let event = TapEvent(
            elapsedSeconds: elapsed,
            target: expectedTarget,
            touchLocation: location,
            expectedCenter: expectedCenter,
            expectedRadius: radius,
            hitCategory: hitCategory
        )
        events.append(event)
    }
    
    private func flashTarget(_ target: TapTarget, state: TargetFlashState) {
        if target == .left {
            leftFlashState = state
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                leftFlashState = .none
            }
        } else {
            rightFlashState = state
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                rightFlashState = .none
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
        
        let completionStatus = (metrics.qualityStatus == .interruptedEarly) ? "Interrupted Early" : "Completed"
        
        let session = MotorSessionRecord(
            accountID: AuthManager.shared.currentUser?.id,
            date: Date(),
            testType: .tapping,
            testedHand: selectedHand,
            durationSeconds: finalElapsed,
            primaryScoreLabel: String(format: "%.1f Hz", metrics.cadenceHz),
            primaryScoreValue: metrics.cadenceHz,
            secondaryScoreLabel: "\(metrics.tapCount) taps",
            qualityStatus: metrics.qualityStatus,
            protocolVersion: metrics.protocolVersion,
            isSampleData: false,
            completionStatus: completionStatus,
            meanCenterDeviationPoints: metrics.meanCenterDeviationPoints,
            meanNormalizedCenterDeviationPercent: metrics.meanNormalizedCenterDeviationPercent,
            totalAttempts: metrics.totalAttempts,
            correctAlternatingTaps: metrics.correctAlternatingTaps,
            alternationAccuracyPercent: metrics.alternationAccuracyPercent
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
    
    @ViewBuilder
    private func instructionRow(number: String, title: String, subtitle: String) -> some View {
        HStack(alignment: .top, spacing: DesignTokens.Spacing.medium) {
            ZStack {
                Circle()
                    .fill(Color.NeuroPulse.motorPrimary.opacity(0.12))
                    .frame(width: 28, height: 28)
                Text(number)
                    .font(.footnote)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.NeuroPulse.motorPrimary)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                Text(subtitle)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

#Preview {
    NavigationStack {
        TappingTestView()
    }
}
