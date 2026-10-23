//
//  SpiralTracingView.swift
//  NeuroPulseAI
//
//  Interactive spiral-tracing assessment with normalized touch coordinates and reference curve.
//

import SwiftUI
import Darwin

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
    @State private var startTicks: UInt64 = 0
    @State private var timebaseInfo = mach_timebase_info()
    @State private var isDrawingActive: Bool = false
    
    private let referencePoints = SpiralFeatureCalculator.generateReferencePoints()
    
    public init() {
        mach_timebase_info(&timebaseInfo)
    }
    
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
            
            Spacer()
            
            Button {
                startDrawing()
            } label: {
                Text("Begin Tracing")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DesignTokens.Spacing.medium)
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
                    Text("TRACE FROM CENTER OUTWARD")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.NeuroPulse.motorSecondary)
                    Text("\(capturedPoints.count) points recorded")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button("Reset") {
                    resetDrawing()
                }
                .font(.footnote)
                .foregroundStyle(Color.NeuroPulse.warning)
            }
            .padding(.horizontal, DesignTokens.Spacing.large)
            .padding(.top, DesignTokens.Spacing.small)
            
            // The Drawing Canvas
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                
                ZStack {
                    // Canvas Card Background
                    RoundedRectangle(cornerRadius: DesignTokens.Radius.card)
                        .fill(Color.NeuroPulse.cardBackground)
                        .shadow(
                            color: DesignTokens.Shadow.cardElevation.color,
                            radius: DesignTokens.Shadow.cardElevation.radius,
                            x: 0,
                            y: 4
                        )
                    
                    // Reference Archimedean Spiral Guide
                    Path { path in
                        guard let first = referencePoints.first else { return }
                        path.move(to: CGPoint(x: first.x * w, y: first.y * h))
                        for pt in referencePoints.dropFirst() {
                            path.addLine(to: CGPoint(x: pt.x * w, y: pt.y * h))
                        }
                    }
                    .stroke(
                        Color.primary.opacity(0.18),
                        style: StrokeStyle(lineWidth: 3, lineCap: .round, dash: [6, 6])
                    )
                    
                    // Center Start Target Dot
                    Circle()
                        .fill(Color.NeuroPulse.brandTeal)
                        .frame(width: 14, height: 14)
                        .position(x: 0.5 * w, y: 0.5 * h)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                                .frame(width: 14, height: 14)
                                .position(x: 0.5 * w, y: 0.5 * h)
                        )
                    
                    // User Drawn Path
                    if !capturedPoints.isEmpty {
                        Path { path in
                            guard let first = capturedPoints.first else { return }
                            path.move(to: CGPoint(x: first.x * w, y: first.y * h))
                            for pt in capturedPoints.dropFirst() {
                                path.addLine(to: CGPoint(x: pt.x * w, y: pt.y * h))
                            }
                        }
                        .stroke(
                            LinearGradient(
                                colors: [Color.NeuroPulse.brandTeal, Color.NeuroPulse.motorSecondary],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round)
                        )
                    }
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
                    Text("Complete Assessment")
                    Image(systemName: "checkmark.circle.fill")
                }
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DesignTokens.Spacing.medium)
                .background(capturedPoints.count >= 20 ? Color.NeuroPulse.motorSecondary : Color.secondary.opacity(0.4))
                .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.medium))
            }
            .disabled(capturedPoints.count < 20)
            .padding(.horizontal, DesignTokens.Spacing.large)
            .padding(.bottom, DesignTokens.Spacing.large)
        }
    }
    
    // MARK: - Logic & Touch Handling
    
    private func startDrawing() {
        capturedPoints = []
        startTicks = mach_absolute_time()
        state = .drawing
    }
    
    private func handleDrag(location: CGPoint, in size: CGSize) {
        guard size.width > 0, size.height > 0 else { return }
        
        let normX = min(max(Double(location.x / size.width), 0.0), 1.0)
        let normY = min(max(Double(location.y / size.height), 0.0), 1.0)
        
        let elapsed = getMonotonicElapsedSeconds()
        let point = SpiralPoint(x: normX, y: normY, elapsedSeconds: elapsed)
        capturedPoints.append(point)
        isDrawingActive = true
    }
    
    private func getMonotonicElapsedSeconds() -> TimeInterval {
        let nowTicks = mach_absolute_time()
        let elapsedTicks = nowTicks >= startTicks ? nowTicks - startTicks : 0
        let elapsedNanos = elapsedTicks * UInt64(timebaseInfo.numer) / UInt64(timebaseInfo.denom)
        return Double(elapsedNanos) / 1_000_000_000.0
    }
    
    private func resetDrawing() {
        capturedPoints = []
        startTicks = mach_absolute_time()
    }
    
    private func finishAssessment() {
        let finalElapsed = getMonotonicElapsedSeconds()
        let metrics = SpiralFeatureCalculator.calculateMetrics(
            userPoints: capturedPoints,
            testedHand: selectedHand,
            actualDuration: finalElapsed
        )
        let session = MotorSessionRecord(
            date: Date(),
            testType: .spiral,
            testedHand: selectedHand,
            durationSeconds: finalElapsed,
            primaryScoreLabel: String(format: "%.1f%% RMSE", metrics.rmsePercent),
            primaryScoreValue: metrics.rmsePercent,
            secondaryScoreLabel: String(format: "%.2fx length", metrics.pathLengthRatio),
            qualityStatus: metrics.qualityStatus,
            protocolVersion: metrics.protocolVersion,
            isSampleData: false
        )
        MotorSessionStore.shared.save(record: session)
        state = .finished(metrics)
    }
}

#Preview {
    NavigationStack {
        SpiralTracingView()
    }
}
