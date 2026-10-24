//
//  SpiralTracingView.swift
//  NeuroPulseAI
//
//  Interactive spiral-tracing assessment with normalized touch coordinates,
//  accelerated Canvas rendering, and asynchronous metric calculations.
//

import SwiftUI

public struct SpiralTracingView: View {
    @Environment(\.dismiss) private var dismiss
    
    public enum TracingState {
        case instructions
        case drawing
        case finished(SpiralMetrics)
    }
    
    @State private var state: TracingState = .instructions
    @State private var selectedHand: String = "Right"
    
    // Drawing capture state
    @State private var capturedPoints: [SpiralPoint] = []
    @State private var startNanos: UInt64 = 0
    @State private var isDrawingActive: Bool = false
    @State private var isCalculating: Bool = false
    
    private let referencePoints = SpiralFeatureCalculator.sharedReferencePoints
    
    public init() {}
    
    public var body: some View {
        ZStack {
            Color.NeuroPulse.surfaceBackground.ignoresSafeArea()
            
            switch state {
            case .instructions:
                instructionsView
            case .drawing:
                drawingCanvasView
            case .finished(let metrics):
                SpiralResultView(metrics: metrics, userPoints: capturedPoints) {
                    dismiss()
                }
            }
        }
        .navigationTitle("Spiral Tracing")
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
    }
    
    // MARK: - Instructions View
    
    private var instructionsView: some View {
        VStack(spacing: DesignTokens.Spacing.large) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.NeuroPulse.motorSecondary.opacity(0.12))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "scribble.variable")
                    .font(.system(size: 46))
                    .foregroundStyle(Color.NeuroPulse.motorSecondary)
            }
            
            VStack(spacing: DesignTokens.Spacing.small) {
                Text("Spiral-Tracing Test")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                
                Text("Trace along the reference spiral from the center dot outward. Try to maintain a continuous, steady movement.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DesignTokens.Spacing.large)
            }
            
            // Hand Selection Picker
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.small) {
                Text("Select Hand")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                
                Picker("Tested Hand", selection: $selectedHand) {
                    Text("Right Hand").tag("Right")
                    Text("Left Hand").tag("Left")
                }
                .pickerStyle(.segmented)
            }
            .padding(.horizontal, DesignTokens.Spacing.large)
            
            Spacer()
            
            Button {
                startDrawing()
            } label: {
                Text("Begin Tracing")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color.NeuroPulse.motorSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.medium))
            }
            .padding(.horizontal, DesignTokens.Spacing.large)
            .padding(.bottom, DesignTokens.Spacing.large)
        }
    }
    
    // MARK: - Interactive Drawing Canvas
    
    private var drawingCanvasView: some View {
        VStack(spacing: DesignTokens.Spacing.medium) {
            // Header instruction
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Trace from Center Outward")
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.NeuroPulse.motorSecondary)
                    Text("\(capturedPoints.count) points recorded")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button("Reset") {
                    resetDrawing()
                }
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color.NeuroPulse.warning)
                .disabled(isCalculating)
            }
            .padding(.horizontal, DesignTokens.Spacing.large)
            .padding(.top, DesignTokens.Spacing.small)
            
            // High-performance Drawing Canvas
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                
                ZStack {
                    // Canvas Card Background
                    RoundedRectangle(cornerRadius: DesignTokens.Radius.card)
                        .fill(Color.NeuroPulse.cardBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignTokens.Radius.card)
                                .stroke(Color.NeuroPulse.subtleBorder, lineWidth: 0.75)
                        )
                        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
                    
                    // Hardware-accelerated Canvas for smooth 60fps rendering
                    Canvas { context, size in
                        let width = size.width
                        let height = size.height
                        
                        // 1. Reference Archimedean Spiral Guide
                        var refPath = Path()
                        if let first = referencePoints.first {
                            refPath.move(to: CGPoint(x: first.x * width, y: first.y * height))
                            for pt in referencePoints.dropFirst() {
                                refPath.addLine(to: CGPoint(x: pt.x * width, y: pt.y * height))
                            }
                        }
                        context.stroke(
                            refPath,
                            with: .color(Color.primary.opacity(0.18)),
                            style: StrokeStyle(lineWidth: 3, lineCap: .round, dash: [6, 6])
                        )
                        
                        // 2. User Drawn Trace Path
                        if !capturedPoints.isEmpty {
                            var userPath = Path()
                            if let first = capturedPoints.first {
                                userPath.move(to: CGPoint(x: first.x * width, y: first.y * height))
                                for pt in capturedPoints.dropFirst() {
                                    userPath.addLine(to: CGPoint(x: pt.x * width, y: pt.y * height))
                                }
                            }
                            context.stroke(
                                userPath,
                                with: .linearGradient(
                                    Gradient(colors: [Color.NeuroPulse.brandTeal, Color.NeuroPulse.motorSecondary]),
                                    startPoint: .zero,
                                    endPoint: CGPoint(x: width, y: height)
                                ),
                                style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round)
                            )
                        }
                    }
                    
                    // Center Start Target Dot (Correctly aligned to reference center)
                    Circle()
                        .fill(Color.NeuroPulse.brandTeal)
                        .frame(width: 14, height: 14)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                        )
                        .position(x: 0.5 * w, y: 0.5 * h)
                }
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            handleDrag(location: value.location, in: geo.size)
                        }
                        .onEnded { _ in
                            isDrawingActive = false
                        }
                )
            }
            .aspectRatio(1.0, contentMode: .fit)
            .padding(.horizontal, DesignTokens.Spacing.large)
            
            // Finish Assessment Button
            Button {
                finishAssessment()
            } label: {
                HStack(spacing: DesignTokens.Spacing.small) {
                    if isCalculating {
                        ProgressView()
                            .tint(.white)
                        Text("Analyzing Trajectory...")
                    } else {
                        Text("Complete Assessment")
                        Image(systemName: "checkmark.circle.fill")
                    }
                }
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(capturedPoints.count >= 20 && !isCalculating ? Color.NeuroPulse.motorSecondary : Color.secondary.opacity(0.4))
                .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.medium))
            }
            .disabled(capturedPoints.count < 20 || isCalculating)
            .padding(.horizontal, DesignTokens.Spacing.large)
            .padding(.bottom, DesignTokens.Spacing.large)
        }
    }
    
    // MARK: - Logic & Touch Handling
    
    private func startDrawing() {
        capturedPoints = []
        startNanos = MonotonicClock.nowNanoseconds()
        state = .drawing
    }
    
    private func handleDrag(location: CGPoint, in size: CGSize) {
        guard size.width > 0, size.height > 0, !isCalculating else { return }
        
        let normX = min(max(Double(location.x / size.width), 0.0), 1.0)
        let normY = min(max(Double(location.y / size.height), 0.0), 1.0)
        let elapsed = getMonotonicElapsedSeconds()
        
        // Jitter filter: avoid recording redundant sub-pixel noise when finger is stationary
        if let last = capturedPoints.last {
            let dx = (normX - last.x) * Double(size.width)
            let dy = (normY - last.y) * Double(size.height)
            let distSq = dx * dx + dy * dy
            if distSq < 2.25 && (elapsed - last.elapsedSeconds) < 0.035 {
                return
            }
        }
        
        let point = SpiralPoint(x: normX, y: normY, elapsedSeconds: elapsed)
        capturedPoints.append(point)
        isDrawingActive = true
    }
    
    private func getMonotonicElapsedSeconds() -> TimeInterval {
        guard startNanos > 0 else { return 0.0 }
        return MonotonicClock.elapsedSeconds(since: startNanos)
    }
    
    private func resetDrawing() {
        capturedPoints = []
        startNanos = MonotonicClock.nowNanoseconds()
    }
    
    private func finishAssessment() {
        guard !isCalculating, capturedPoints.count >= 20 else { return }
        isCalculating = true
        
        let finalElapsed = getMonotonicElapsedSeconds()
        let points = capturedPoints
        let hand = selectedHand
        
        // Offload metric calculation to background task to guarantee smooth UI
        Task.detached(priority: .userInitiated) {
            let metrics = SpiralFeatureCalculator.calculateMetrics(
                userPoints: points,
                testedHand: hand,
                actualDuration: finalElapsed
            )
            
            await MainActor.run {
                let session = MotorSessionRecord(
                    accountID: AuthManager.shared.currentUser?.id,
                    date: Date(),
                    testType: .spiral,
                    testedHand: hand,
                    durationSeconds: finalElapsed,
                    primaryScoreLabel: String(format: "%.1f%% RMSE", metrics.rmsePercent),
                    primaryScoreValue: metrics.rmsePercent,
                    secondaryScoreLabel: String(format: "%.2fx length", metrics.pathLengthRatio),
                    qualityStatus: metrics.qualityStatus,
                    protocolVersion: metrics.protocolVersion,
                    isSampleData: false
                )
                MotorSessionStore.shared.save(record: session)
                self.state = .finished(metrics)
                self.isCalculating = false
            }
        }
    }
}

#Preview {
    NavigationStack {
        SpiralTracingView()
    }
}
